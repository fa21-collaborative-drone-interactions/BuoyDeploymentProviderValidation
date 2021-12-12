//
// This source file is part of the FA2021 open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Apodini
import Foundation
import BuoyDeploymentOption

struct SensorData: Handler {
    static let dirPath = "data"

    func handle() -> [SensorDump] {
        readJSONDirectory(SensorDump.self, dirPath: Self.dirPath)
            .map {
                SensorDump(
                    buoyID: $0.buoyID,
                    date: $0.date,
                    location: $0.location,
                    measurements: $0.measurements.map { item in
                        MeasurementItem(
                            sensorID: item.sensorID,
                            sensorType: item.sensorType,
                            measurement: getMeasurementConverterInstance(sensorType: item.sensorType).convert(rawValue: item.measurement))
                    }
                )
            }
    }

    var content: some Component {
        Group(TemperatureSensor.sensorType.description) {
            TemperatureSensor()
        }.metadata(
            DeploymentDevice(.temperature)
        )

        Group(ConductivitySensor.sensorType.description) {
            ConductivitySensor()
        }.metadata(
            DeploymentDevice(.conductivity)
        )

        Group(PhSensor.sensorType.description) {
            PhSensor()
        }.metadata(
            DeploymentDevice(.ph)
        )
    }
}
