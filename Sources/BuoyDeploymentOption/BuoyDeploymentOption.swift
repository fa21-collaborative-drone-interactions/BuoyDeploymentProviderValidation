import Apodini
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
