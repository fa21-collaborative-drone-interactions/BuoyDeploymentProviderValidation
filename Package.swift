// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "buoy-deployment-provider",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "BuoyDeploymentOption",
            targets: ["BuoyDeploymentOption"]
        ),
        .executable(
            name: "BuoyDeploymentTarget",
            targets: ["BuoyDeploymentTarget"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Apodini/Apodini.git", .upToNextMinor(from: "0.5.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/Apodini/ApodiniIoTDeploymentProvider", .branch("develop")),
    ],
    targets: [
        .target(
            name: "BuoyDeploymentOption",
            dependencies: [
                .product(name: "ApodiniDeployBuildSupport", package: "Apodini"),
                .product(name: "DeploymentTargetIoTCommon", package: "ApodiniIoTDeploymentProvider")
            ]
        ),
        .executableTarget(
            name: "BuoyDeploymentTarget",
            dependencies: [
                .target(name: "BuoyDeploymentOption"),
                .product(name: "DeploymentTargetIoT", package: "ApodiniIoTDeploymentProvider"),
                .product(name: "DeploymentTargetIoTCommon", package: "ApodiniIoTDeploymentProvider"),
                .product(name: "ApodiniDeployBuildSupport", package: "Apodini"),
                .product(name: "ApodiniUtils", package: "Apodini")
            ]
        ),
        .testTarget(
            name: "BuoyDeploymentProviderTests"
        )
    ]
)
