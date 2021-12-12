//
// This source file is part of the FA2021 open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import Apodini

struct SensorDescription: Content {
    let name: String
    let type: SensorType

    init(type: SensorType) {
        self.type = type
        self.name = type.description
    }
}
