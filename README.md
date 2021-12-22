<!--
# This source file is part of the FA2021 open source project
#
# SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
#
# SPDX-License-Identifier: MIT
-->

# FA 2021 Deployment Provider Validation

[![Build and Test](https://github.com/fa21-collaborative-drone-interactions/BuoyDeploymentProviderValidation/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/fa21-collaborative-drone-interactions/BuoyDeploymentProviderValidation/actions/workflows/build-and-test.yml)

This repository contains the setup and evaluation scripts for the automatic web service deployment using the Apodini IoT Deployment Provider that was used for the FA 2021 project.

## Setup
The evaluation has been conducted with a total of **3** Raspberry Pis (A, B, C). 
Each Raspberry Pi is incorporated in a FA 2021 buoy and connected to different sensors: PH, conductivity, and temperature sensors.
In the complete setup, the microcontroller writes a file containing the types of sensors that are available to the SD card of the Raspberry Pi.
To make this validation easily reproducible, we recreate the setup without the need for microcontrollers, sensors, and buoy hardware and create the files in the Raspberry Pi Setup section.
For the evaluation, the following sensor setup was used:
 - Raspberry Pi A: PH sensor and temperature sensor
 - Raspberry Pi B: Conductivity sensor and temperature sensor
 - Raspberry Pi C: PH sensor 
All Raspberry Pis must be located in a network, connected via Ethernet, as the WiFi module is used for creating access points.

### Raspberry Pi Setup

1. Use an Imager such as the [https://www.raspberrypi.com/software/](Raspberry Pi Imager) to flash an [Ubuntu Server 21.10 64-bit](https://ubuntu.com/raspberry-pi/server) on an SD card.
2. Start the Raspberry Pi with the SD card, connect to the Raspberry Pi using SSH, and change the default password.
3. SSH into the Raspberry Pi, clone this repository, or copy the script to the Raspberry Pi using `scp` and run the `setup.sh` script (found in the "Scripts" folder) to set up the wireless access point, docker installation, and avahi. The Raspberry Pi restarts after the script is complete. 
 - Pass the letter of the buoy to the setup script (the default value is `A`), e.g.: `setup.sh B`. 
 - You can also modify the WiFi password as a second argument: `setup.sh B SuperSecretPassword`.
4. Check that the wireless access point is running. It corresponds to the letter of the buoy instance, e.g., `BuoyAPA`, and the password is set the same as the access point name if you have not set a separate password.
5. Create a JSON file containing the available sensors for each of the buoy Raspberry Pis. Change the file at `/buoy/available_sensors.json` to define the connected sensors for that buoy. The JSON file consists of an array of numbers, like: `[0,1]`. The sensors are coded as follows: 
 0: Temperature sensor
 1: Conductivity sensor
 2: PH sensor
6. (Optional) If you use an `docker-compose.yml` or a Swift package as the input type of the web service, make sure that a password-less ssh connection can be established between the raspberry pis and the provider machine, e.g. by using `copy-ssh-id`. This is not required if the web service is provided as a Docker image. 

## FA 2021 Deployment Provider

The FA 2021 Deployment Provider is based on the [Apodini IoT Deployment Provider](https://github.com/Apodini/ApodiniIoTDeploymentProvider).
The web service that was used for the evaluation/deployment is the [BuoyWebService](https://github.com/Apodini/buoy-web-service), which was forked from the original web service [here](https://github.com/fa21-collaborative-drone-interactions/buoy-web-service) in order to add the deployment options. 
The core functionality was not altered.
The web service is also added as an executable target to this project.

### Configure the FA 2021 Deployment Provider
To allow a non-interactive setup, you can pass a credentials file that will hold the credentials for the docker images and the Raspberry Pi-based IoT gateways.
The docker images used in the FA 2021 Deployment Providers are public docker images hosted in the GitHub Package Registry. Therefore no docker credentials are needed.
This repository contains a default credentials file in this repository, `credentials.json`, that can be passed to the provider, as shown in the next section.

### Run the FA 2021 Deployment Provider

The deployment requires a docker compose file defining the deployable web service.
Run the provider, by using `swift run BuoyDeploymentTarget --docker-compose-path docker-compose.yml --config-file credentials.json`.
The provider automatically dumps the logs in the `/Logs` directory.

### Run the Provider as part of a GitHub Action

For the evaluation of the thesis, the provider was run as part of a GitHub Action.
Have a look at the web service's repository ([buoy-web-service](https://github.com/Apodini/buoy-web-service)) to get more details on the action.
Adding a custom runner should allow testing the deployment as part of the CI.
Please note that the runner needs to be able to build and run Swift code.
The action references a different repo for the provider; however, it contains the same functionality.
There are two GitHub actions related to the deployment. One does a [single deployment](https://github.com/Apodini/buoy-web-service/blob/develop/.github/workflows/deploy.yml) when a new commit is pushed. 
The other does the [evaluation](https://github.com/Apodini/buoy-web-service/blob/develop/.github/workflows/evaluate_buoy.yml), this means the deployment is conducted 20 times. 10x new deployment (i.e., new download) and 10x recurring deployment (no download). 

You can test the deployment using the `buoy_simulation.sh` script. You can pass the IP addresses of the RaspberryPis to the script: `buoy_simulation.sh IP1 IP2 IP3`.
To not be prompted for the password multiple times, run `ssh-copy-id username@ipaddress` with the username (probably ubuntu) and the IP address of your Raspberry Pi on your machine to enable a more straightforward keyless ssh login.

### Run the Provider to test the redeployment 

In order to test the redeployment, use redeploy simulation shell script `redeploy_simulation.sh PROVIDER_DELAY IP1 IP2 IP3`.
`PROVIDER_DELAY` specifies how long the deployment provider waits between each network scan.
You can pass the IP addresses of the RaspberryPis to the script after the `PROVIDER_DELAY`.

To not be prompted for the password multiple times, run `ssh-copy-id username@ipaddress` with the username (probably ubuntu) and the IP address of your Raspberry Pi on your machine to enable a more straightforward keyless ssh login.

It is recommended to set this something low, e.g., 5 seconds. The script iterates over eight different REQUEST_DELAYS.
A request delay specifies how long the script waits after a change occurs to send a request to the web service.
The machine running the Deployment Provider needs to be in the same network as the Raspberry Pi buoys when they are in the maintenance/development setting before being deployed to a body of water.
Ensure that no docker containers are running on the Raspberry Pis and that the avahi-daemon is running on all Raspberry Pis.
Everything else should be handled by the script.
The execution times are highly dependent on the specified request delay.

## Contributing
Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/Apodini/.github/blob/main/CONTRIBUTING.md) first.

## License
This project is licensed under the MIT License. See [License](https://github.com/Apodini/Apodini/blob/reuse/LICENSES/MIT.txt) for more information.

## Code of conduct
For our code of conduct see [Code of conduct](https://github.com/Apodini/.github/blob/main/CODE_OF_CONDUCT.md).
