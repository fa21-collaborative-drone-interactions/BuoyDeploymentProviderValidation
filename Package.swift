// swift-tools-version:5.5

//
// This source file is part of the FA2021 open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

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
        ),
        .executable(
            name: "WebService",
            targets: ["WebService"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Apodini/Apodini.git", .upToNextMinor(from: "0.6.1")),
        .package(url: "https://github.com/Apodini/ApodiniIoTDeploymentProvider", .upToNextMinor(from: "0.1.0"))
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
        .executableTarget(
            name: "WebService",
            dependencies: [
                .product(name: "Apodini", package: "Apodini"),
                .product(name: "ApodiniHTTP", package: "Apodini"),
                .product(name: "ApodiniDeploy", package: "Apodini"),
                .product(name: "DeploymentTargetIoTRuntime", package: "ApodiniIoTDeploymentProvider"),
                .target(name: "BuoyDeploymentOption")
            ]
        )
    ]
)
