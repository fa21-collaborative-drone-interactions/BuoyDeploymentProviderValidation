//
// This source file is part of the FA2021 open source project
//
// SPDX-FileCopyrightText: 2019-2021 Paul Schmiedmayer and the project authors (see CONTRIBUTORS.md) <paul.schmiedmayer@tum.de>
//
// SPDX-License-Identifier: MIT
//

import ArgumentParser
import DeploymentTargetIoT

@main
struct BuoyIotDeploymentCLI: ParsableCommand {
    static var configuration: CommandConfiguration {
        CommandConfiguration(
            abstract: "Buoy Deployment Provider",
            discussion: "Contains Buoy deployment related commands",
            version: "0.0.1",
            subcommands: [BuoyDeployCommand.self, KillSessionCommand.self],
            defaultSubcommand: BuoyDeployCommand.self
        )
    }
}
