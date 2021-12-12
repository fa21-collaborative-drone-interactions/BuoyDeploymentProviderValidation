<!--
# This source file is part of the FA2021 open source project
#
# SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
#
# SPDX-License-Identifier: MIT
-->

# FA Deployment Provider - Evaluation

## Setup
The evaluation has been conducted with a total of **3** Raspberry Pis (A, B, C), to which are different sensors connected. The different sensors are PH, conductivity and temperature. For simplicity reason, the connection of the sensors is only simulated. Therefore, to recreate the setup no real sensors are needed. 
For the evaluation, the following sensor setup was used:

 - Pi A: PH sensor, Temp. sensor
 - Pi B: Conductivity sensor, Temperature sensor
 - Pi C: PH sensor.
 
 The web service that was used for the evaluation/deployment is the [BuoyWebService](https://github.com/Apodini/buoy-web-service), which was forked from the original web service [here](https://github.com/fa21-collaborative-drone-interactions/buoy-web-service) in order to add the deployment options. The core functionality was not touched. 

### General Setup

 1. Boot all pis using [this image](https://github.com/fa21-collaborative-drone-interactions/BuoyAP). This should pre-configure access point, docker, etc.)
 2. Download and start avahi by:
    1. sudo apt-get install avahi-utils avahi-daemon
    2. edit /etc/avahi/avahi-daemon.conf
         `publish-hinfo=yes`
         `publish-workstation=yes`
    3. sudo systemctl enable avahi-daemon.service
    4. sudo systemctl start avahi-daemon.service
    Alternatively you can also download and run [this script](https://github.com/Apodini/ApodiniIoTDeploymentProvider/blob/develop/scripts/setup-IoT.sh)
3. Enable keyless ssh login by running: 
    `ssh-copy-id username@ipaddress`
4. (Optional) In my tests I sometimes had the issue that the free space was always around 7-8gb even with bigger sd cards. If you notice something similar, I can recommend [this guide]
5. For each Pi, edit the json under `/buoy/available_sensors.json` to set the connected sensors for that Pi. The json file consists of an array of numbers, like: `[0,1]`. The sensors are coded as follows: 
    0: temperature
    1: conductivity
    2: ph
    
    
### Run the Provider

Similiar to the Jass deployment provider ([here](https://github.com/fa21-collaborative-drone-interactions/BuoyDeploymentProviderValidation)), it is recommended to pass a credentials file the provider to fully automate the deployment. The used images are located in public repositories. Thus no credentials need to be provided. The default configuration file `credentials.json` need to referenced when starting the provider, as shown below. 

Run the provider, by using `swift run BuoyDeploymentTarget --docker-compose-path PATH_TO_COMPOSE_YML --config-file PATH_TO_CREDENTIAL_FILE`. The provider dumps the logs automatically in `/Logs`.  

### Run the Provider as part of a github action

For the evaluation of the thesis, the provider was run as part of a github action. Have a look at the web service's repository ([here](https://github.com/Apodini/buoy-web-service)) to get more details on the action. Adding a custom runner should allow to test the deployment as part of the CI. The `setup-IoT-runner.sh` script might be helpful to automate the swift installation. The action references a different repo for the provider. However, it contains the same functionality. There are two github actions related to the deployment. One does a [single deployment](https://github.com/Apodini/buoy-web-service/blob/develop/.github/workflows/deploy.yml) when a new commit is pushed. The other does the [evaluation](https://github.com/Apodini/buoy-web-service/blob/develop/.github/workflows/evaluate_buoy.yml), this means the deployment is conducted 20 times. 10x new deployment (i.e., new download) and 10x recurring deployment (no download). 

### Run the Provider to test the redeployment 

In order to test the redeployment, use this shell script `redeploy_simulation.sh REQUEST_DELAY`. REQUEST_DELAY specifies how long the script waits after a change occurred to send a request to the web service. Make sure, the machine you run this script on is in the same network as the pis. Ensure that no docker containers are running on the Pis and that the avahi-daemon is running on all pis. Everything else should be handled by the script. The execution times are highly dependent on the specified request delay. 

## Last Remarks
I hope this clarifies setup and usage of the provider. If you encounter any problems or run into some issues, feel free to reach out to me.
