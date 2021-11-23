import Apodini
import ApodiniDeployBuildSupport
import DeploymentTargetIoTCommon
import Foundation

extension DeploymentDevice {
    public static var temperature: Self {
        DeploymentDevice(rawValue: "temperature")
    }
    
    public static var conductivity: Self {
        DeploymentDevice(rawValue: "conductivity")
    }

    public static var ph: Self {
        DeploymentDevice(rawValue: "ph")
    }
}