import Apodini
//
// This source file is part of the FA2021 open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import ApodiniDeployBuildSupport
import DeploymentTargetIoTCommon
import Foundation

extension DeploymentDevice {
    /// `DeploymentDevice` metadata for Temperature
    public static var temperature: Self {
        DeploymentDevice(rawValue: "temperature")
    }
    
    /// `DeploymentDevice` metadata for conductivity
    public static var conductivity: Self {
        DeploymentDevice(rawValue: "conductivity")
    }

    /// `DeploymentDevice` metadata for ph
    public static var ph: Self { // swiftlint:disable:this identifier_name
        DeploymentDevice(rawValue: "ph")
    }
}
