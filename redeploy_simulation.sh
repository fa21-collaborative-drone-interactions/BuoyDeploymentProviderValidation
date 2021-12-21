#
# This source file is part of the FA2021 open source project
#
# SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
#
# SPDX-License-Identifier: MIT
#

RED='\033[0;31m'
GREEN='\033[0;32m'
DEFAULT='\033[0m'

IP1="${2:-192.168.178.50}"
IP2="${3:-192.168.178.51}"
IP3="${4:-192.168.178.52}"

# You can pass the addresses to the script as arguments
addresses=( "ubuntu@$IP1" "ubuntu@$IP2" "ubuntu@$IP3" )
ipAddresses=( "$IP1" "$IP2" "$IP3" )
# The integer values of the sensors
sensorValues=()
# The sensors in a string format that can written in the available_sensors.json
sensors=()
# The sensor names
sensorNames=( "temperature" "conductivity" "ph" )

errorOccurred=false

sleepTimes=( "300" "240" "210" "180" "150" "120" "90" "60" "30" )

failedCalls=0
totalCalls=51

function reset() {
    for addresses in "${addresses[@]}"; do
        ssh $addresses "docker stop buoy-web-service; docker rm buoy-web-service; docker image prune -a -f"
    done
}

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
        ((failedCalls=failedCalls+1))
    fi
}

function evaluate() {
    if [ "$errorOccurred" = false ]; then
        echo "${GREEN}\xE2\x9C\x94 $1 was successful!${DEFAULT}"
    else
        echo "${RED}$1 failed!${DEFAULT}"
    fi
    
    # Resetting error
    errorOccurred=false
}

echo "${addresses[*]}"

echo "total,failed,time" > "simulation_results_$1.csv"

ssh ${addresses[0]} 'sudo mkdir /buoy'
ssh ${addresses[1]} 'sudo mkdir /buoy'
ssh ${addresses[2]} 'sudo mkdir /buoy'

reset

for sleepTime in "${sleepTimes[@]}"; do
    echo "#######################################"
    echo "Evaluating with $sleepTime seconds interval"
    echo "Using $1 seconds provider interval"
    echo "######################################"
  
    echo "Setting initial sensors on the gateways"
    
    echo "${addresses[0]}"

    echo "Copy sensor content to available_sensors.json"
    ssh ${addresses[0]} 'echo "[0,2]" | sudo tee /buoy/available_sensors.json'
    ssh ${addresses[1]} 'echo "[0,1]" | sudo tee /buoy/available_sensors.json'
    ssh ${addresses[2]} 'echo "[2]" | sudo tee /buoy/available_sensors.json'
    
    echo "Making sure everything is discoverable"
    ssh ${addresses[0]} 'sudo systemctl start avahi-daemon.service'
    ssh ${addresses[1]} 'sudo systemctl start avahi-daemon.service'
    ssh ${addresses[2]} 'sudo systemctl start avahi-daemon.service'
  
    echo "Starting the Deployment Provider"
    tmux new-session -d -s sim "swift run BuoyDeploymentTarget --config-file credentials.json --docker-compose-path docker-compose.yml --automatic-redeploy --redeployment-interval $1"

    echo "Waiting for initial deployment..."
    sleep 340
  
    echo "Testing initial deployment"
    call ${ipAddresses[0]} 0 true
    call ${ipAddresses[0]} 1 false
    call ${ipAddresses[0]} 2 true

    call ${ipAddresses[1]} 0 true
    call ${ipAddresses[1]} 1 true
    call ${ipAddresses[1]} 2 false

    call ${ipAddresses[2]} 0 false
    call ${ipAddresses[2]} 1 false
    call ${ipAddresses[2]} 2 true

    # Evaluate result
    evaluate "Initial deployment"
    
    echo "Turn gateway ${ipAddresses[0]} off. Expect endpoints to be not available anymore."
    ssh ${addresses[0]} 'sudo systemctl stop avahi-daemon.service'
    sleep $sleepTime
    call ${ipAddresses[0]} 0 false
    call ${ipAddresses[0]} 1 false
    call ${ipAddresses[0]} 2 false

    evaluate "Testing leaving IoT gateway"

    echo "Turn device ${ipAddresses[0]} on again. Expect endpoints to be available again."
    ssh ${addresses[0]} 'sudo systemctl start avahi-daemon.service'
    sleep $sleepTime
    call ${ipAddresses[0]} 0 true
    call ${ipAddresses[0]} 1 false
    call ${ipAddresses[0]} 2 true

    evaluate "Testing joining IoT gateway"

    echo "Testing joining and leaving IoT devices.."
    ssh ${addresses[0]} 'echo "[1]" | sudo tee /buoy/available_sensors.json'
    ssh ${addresses[1]} 'echo "[2]" | sudo tee /buoy/available_sensors.json'
    ssh ${addresses[2]} 'echo "[]" | sudo tee /buoy/available_sensors.json'

    sleep $sleepTime
    call ${ipAddresses[0]} 0 false
    call ${ipAddresses[0]} 1 true
    call ${ipAddresses[0]} 2 false

    call ${ipAddresses[1]} 0 false
    call ${ipAddresses[1]} 1 false
    call ${ipAddresses[1]} 2 true

    call ${ipAddresses[2]} 0 false
    call ${ipAddresses[2]} 1 false
    call ${ipAddresses[2]} 2 false

    evaluate "Testing joining and leaving IoT devices - case 1"

    ssh ${addresses[0]} 'echo "[0]" | sudo tee /buoy/available_sensors.json'
    sleep $sleepTime
    call ${ipAddresses[0]} 0 true
    call ${ipAddresses[0]} 1 false
    call ${ipAddresses[0]} 2 false

    evaluate "Testing joining and leaving IoT devices - case 2"

    ssh ${addresses[1]} 'echo "[1,2]" | sudo tee /buoy/available_sensors.json'
    sleep $sleepTime
    call ${ipAddresses[1]} 0 false
    call ${ipAddresses[1]} 1 true
    call ${ipAddresses[1]} 2 true

    evaluate "Testing joining and leaving IoT devices - case 3"

    ssh ${addresses[2]} 'echo "[0,1,2]" | sudo tee /buoy/available_sensors.json'
    sleep $sleepTime
    call ${ipAddresses[2]} 0 true
    call ${ipAddresses[2]} 1 true
    call ${ipAddresses[2]} 2 true

    evaluate "Testing joining and leaving IoT devices - case 4"

    ssh ${addresses[0]} 'echo "[0,1,2]" | sudo tee /buoy/available_sensors.json'
    sleep $sleepTime
    call ${ipAddresses[0]} 0 true
    call ${ipAddresses[0]} 1 true
    call ${ipAddresses[0]} 2 true

    evaluate "Testing joining and leaving IoT devices - case 5"

    ssh ${addresses[0]} 'echo "[]" | sudo tee /buoy/available_sensors.json'
    sleep $sleepTime
    call ${ipAddresses[0]} 0 false
    call ${ipAddresses[0]} 1 false
    call ${ipAddresses[0]} 2 false

    evaluate "Testing joining and leaving IoT devices - case 6"

    ssh ${addresses[0]} 'echo "[2]" | sudo tee /buoy/available_sensors.json'
    sleep $sleepTime
    call ${ipAddresses[0]} 0 false
    call ${ipAddresses[0]} 1 false
    call ${ipAddresses[0]} 2 true

    evaluate "Testing joining and leaving IoT devices - case 7"

    ssh ${addresses[2]} 'echo "[0,1]" | sudo tee /buoy/available_sensors.json'
    sleep $sleepTime
    call ${ipAddresses[2]} 0 true
    call ${ipAddresses[2]} 1 true
    call ${ipAddresses[2]} 2 false

    evaluate "Testing joining and leaving IoT devices - case 8"

    echo "Turn gateway ${ipAddresses[1]} off. Expect endpoints to be not available anymore."
    ssh ${addresses[1]} 'sudo systemctl stop avahi-daemon.service'
    sleep $sleepTime
    call ${ipAddresses[1]} 0 false
    call ${ipAddresses[1]} 1 false
    call ${ipAddresses[1]} 2 false

    evaluate "Testing leaving IoT gateway"

    echo "Turn device ${ipAddresses[1]} on again. Expect endpoints to be available again."
    ssh ${addresses[1]} 'echo "[0,2]" | sudo tee /buoy/available_sensors.json'
    ssh ${addresses[1]} 'sudo systemctl start avahi-daemon.service'
    sleep $sleepTime
    call ${ipAddresses[1]} 0 true
    call ${ipAddresses[1]} 1 false
    call ${ipAddresses[1]} 2 true

    evaluate "Testing joining IoT gateway"
    
    echo "51,$failedCalls,$sleepTime" >> "simulation_results_$1.csv"
    failedCalls=0
    tmux kill-session -t sim
    
done

reset