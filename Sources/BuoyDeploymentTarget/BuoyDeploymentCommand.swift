//
// This source file is part of the FA2021 open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import ArgumentParser
import BuoyDeploymentOption
import DeploymentTargetIoTCommon
import DeploymentTargetIoT
import DeviceDiscovery
import Foundation

struct BuoyDeployCommand: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            commandName: "deploy",
            abstract: "Buoy Deployment Provider",
            discussion: "Runs the Buoy deployment provider",
            version: "0.0.1"
        )
    }
    
    @Argument(parsing: .unconditionalRemaining, help: "CLI arguments of the web service")
    var webServiceArguments: [String] = []

    @Option
    var types: String = "_workstation._tcp."

    @Option
    var deploymentDir: String = "/deployment"

    @Option
    var dockerComposePath: String
//    var dockerComposePath: String = "/Users/felice/Documents/buoy-web-service/docker-compose.yml"
    
    @Option
    var configFile: String
//    var configFile: String = "/Users/felice/Documents/buoy-deployment-provider/config.json"
    
    @Option(help: "The interval stating how frequent the provider tries to redeploy")
    var redeploymentInterval: Int = 30
    
    @Flag(help: "If set, the deployment provider listens for changes in the working directory and automatically redeploys them."
    )
    var automaticRedeploy = false
    
    func run() throws {
        let provider = IoTDeploymentProvider(
            searchableTypes: types.split(separator: ",").map { DeviceIdentifier(String($0)) },
            deploymentDir: deploymentDir,
            automaticRedeployment: automaticRedeploy,
            webServiceArguments: webServiceArguments,
            input: .dockerCompose(URL(fileURLWithPath: dockerComposePath)),
            port: 80,
            configurationFile: URL(fileURLWithPath: configFile),
            dumpLog: true,
            redeploymentInterval: TimeInterval(redeploymentInterval)
        )
        registerSensorPostDiscovery(provider, device: .temperature, sensorType: 0, actionName: "temperature")
        registerSensorPostDiscovery(provider, device: .conductivity, sensorType: 1, actionName: "conductivity")
        registerSensorPostDiscovery(provider, device: .ph, sensorType: 2, actionName: "ph")
        try provider.run()
    }

    func registerSensorPostDiscovery(_ provider: IoTDeploymentProvider, device: DeploymentDevice, sensorType: Int, actionName: String) {
        provider.registerAction(
            scope: .all,
            action: .docker(
                        DockerDiscoveryAction(
                            identifier: ActionIdentifier(actionName),
                            imageName: "ghcr.io/fa21-collaborative-drone-interactions/buoypostdiscovery:latest",
                            fileUrl: URL(fileURLWithPath: deploymentDir).appendingPathComponent(actionName),
                            options: [
                                .command("\(sensorType) \(actionName)"),
                                .volume(hostDir: "/buoy", containerDir: "/buoy"),
                                .volume(hostDir: deploymentDir, containerDir: "/result"),
                                .credentials(username: "", password: "") // docker image is public
                            ]
                        )
                    ),
            option: DeploymentDeviceMetadata(device)
        )
    }
}
