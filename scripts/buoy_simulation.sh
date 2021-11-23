GREEN='\033[0;32m'
DEFAULT='\033[0m'

EXEC_PATH=".build/debug/BuoyDeploymentTarget --config-file config.json --docker-compose-path buoy-deployment-provider/docker-compose.yml"

ipAddresses=( "192.168.2.116" "192.168.2.118" "192.168.2.119" )
sensorNames=( "temperature" "conductivity" "ph" )

function reset() {
    for ipAddress in "${ipAddresses[@]}"; do
        ssh ubuntu@$ipAddress "docker stop ApodiniIoTDockerInstance; docker rm ApodiniIoTDockerInstance; docker image prune -a -f"
    done
}

function stop() {
    echo "Stopping running instances"
    for ipAddress in "${ipAddresses[@]}"; do
        ssh ubuntu@$ipAddress "docker stop ApodiniIoTDockerInstance"
    done
}


ssh ubuntu@${ipAddresses[0]} 'echo "[0,2]" >| /buoy/available_sensors.json'
ssh ubuntu@${ipAddresses[1]} 'echo "[0,1]" >| /buoy/available_sensors.json'
ssh ubuntu@${ipAddresses[2]} 'echo "[2]" >| /buoy/available_sensors.json'

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
    ./$EXEC_PATH
    evaluate
done

sleep 300
echo "Testing without docker reset. Assuming needed images are already downloaded"

for ((i=1;i<=10;i++)); do
    stop
    ./$EXEC_PATH
    evaluate
done

if [ "$errorOccurred" = false ]; then
    echo "${GREEN}\xE2\x9C\x94 Run was successful!${DEFAULT}"
else
    echo "${RED}Run failed!${DEFAULT}"
fi

