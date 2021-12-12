//
// This source file is part of the FA2021 open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Apodini

struct SensorDump: Content, Decodable {
    var buoyID: Int
    var date: String
    var location: Location
    var measurements: [MeasurementItem]

    func filteredBySensorType(_ sensorType: SensorType) -> SensorDump {
        SensorDump(
            buoyID: self.buoyID,
            date: self.date,
            location: self.location,
            measurements: self.measurements.filter { $0.sensorType == sensorType }
        )
    }

    func convertMeasurements(_ converter: MeasurementConverter) -> SensorDump {
        SensorDump(
            buoyID: self.buoyID,
            date: self.date,
            location: self.location,
            measurements: self.measurements.map { item in
                MeasurementItem(sensorID: item.sensorID, sensorType: item.sensorType, measurement: converter.convert(rawValue: item.measurement))
            }
        )
    }
}

struct Location: Content, Decodable {
    var latitude: Double
    var longitude: Double
}

struct MeasurementItem: Content, Decodable {
    var sensorID: Int
    var sensorType: SensorType
    var measurement: Double
}

enum SensorType: Int, Content, Decodable, CustomStringConvertible {
    case TEMPERATURE
    case CONDUCTIVITY
    case POTENTIAHYDROGENII

    var description: String {
        switch self {
        case .TEMPERATURE: return "temperature"
        case .CONDUCTIVITY: return "conductivity"
        case .POTENTIAHYDROGENII: return "ph"
        }
    }
}
