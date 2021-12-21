#
# This source file is part of the FA2021 open source project
#
# SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
#
# SPDX-License-Identifier: MIT
#

GREEN='\033[0;32m'
DEFAULT='\033[0m'

# You can pass the addresses to the script as arguments
IP1="${1:-192.168.178.50}"
IP2="${2:-192.168.178.51}"
IP3="${3:-192.168.178.52}"
ipAddresses=( "$IP1" "$IP2" "$IP3" )
sensorNames=( "temperature" "conductivity" "ph" )
errorOccurred=false

function reset() {
    for ipAddress in "${ipAddresses[@]}"; do
        ssh ubuntu@$ipAddress "docker stop buoy-web-service; docker rm buoy-web-service; docker image prune -a -f"
    done
}

function stop() {
    echo "Stopping running instances"
    for ipAddress in "${ipAddresses[@]}"; do
        ssh ubuntu@$ipAddress "docker stop buoy-web-service"
    done
}


ssh ubuntu@${ipAddresses[0]} 'sudo mkdir /buoy && echo "[0,2]" | sudo tee /buoy/available_sensors.json'
ssh ubuntu@${ipAddresses[1]} 'sudo mkdir /buoy && echo "[0,1]" | sudo tee /buoy/available_sensors.json'
ssh ubuntu@${ipAddresses[2]} 'sudo mkdir /buoy && echo "[2]" | sudo tee /buoy/available_sensors.json'

function call() {
    currentCall=$1:80/v1/data/${sensorNames[$2]}
    call=$(curl -s -o /dev/null -w "%{http_code}" $currentCall)
    if [ $call -eq 200 ] && $3; then
        echo "${GREEN}\xE2\x9C\x94 SUCCESS${DEFAULT}: $currentCall was successful"
    elif [ $call -ne 200 ] && ! $3; then
        echo "${GREEN}\xE2\x9C\x94 SUCCESS${DEFAULT}: $currentCall was expected to fail."
    else
        echo "${RED}ERROR${DEFAULT}: $currentCall failed unexpected."
        errorOccurred=true
    fi
}

function evaluate() {
    call ${ipAddresses[0]} 0 true
    call ${ipAddresses[0]} 1 false
    call ${ipAddresses[0]} 2 true

    call ${ipAddresses[1]} 0 true
    call ${ipAddresses[1]} 1 true
    call ${ipAddresses[1]} 2 false

    call ${ipAddresses[2]} 0 false
    call ${ipAddresses[2]} 1 false
    call ${ipAddresses[2]} 2 true
}

echo "Testing normal deployment. Downloading images only on first run"

for ((i=1;i<=10;i++)); do
    reset
    swift run BuoyDeploymentTarget --config-file credentials.json --docker-compose-path docker-compose.yml
    evaluate
done

sleep 10
echo "Testing without docker reset. Assuming needed images are already downloaded"

for ((i=1;i<=10;i++)); do
    stop
    swift run BuoyDeploymentTarget --config-file credentials.json --docker-compose-path docker-compose.yml
    evaluate
done

reset

if [ "$errorOccurred" = false ]; then
    echo "${GREEN}\xE2\x9C\x94 Run was successful!${DEFAULT}"
else
    echo "${RED}Run failed!${DEFAULT}"
fi

