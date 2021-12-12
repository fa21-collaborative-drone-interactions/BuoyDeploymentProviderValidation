//
// This source file is part of the FA2021 open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Apodini
import ApodiniHTTP
import ArgumentParser
import DeploymentTargetIoTRuntime
import ApodiniDeploy

@main
struct BuoyWebService: WebService {
    var configuration: Configuration {
        HTTP()
        ApodiniDeploy(runtimes: [IoTRuntime<Self>.self])
    }

    var content: some Component {
        Group("sensors") {
            Sensor()
        }.metadata(DeploymentDevice(.default))

        Group("data") {
            SensorData()
        }
    }
}
