//
// This source file is part of the FA2021 open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Apodini
import Foundation


struct Sensor: Handler {
    func handle() -> [SensorDescription] {
        readJSONFromFile([SensorType].self, filePath: "available_sensors.json")?.map { SensorDescription(type: $0) } ?? []
    }
}
