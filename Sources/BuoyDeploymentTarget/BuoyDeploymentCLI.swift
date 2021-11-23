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
