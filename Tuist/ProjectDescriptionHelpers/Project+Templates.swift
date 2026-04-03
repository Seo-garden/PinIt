import ProjectDescription

public extension Project {
    static func makeModule(
        name: String,
        destinations: Destinations = .iOS,
        product: Product,
        bundleId: String? = nil,
        deploymentTargets: DeploymentTargets = .iOS("17.0"),
        infoPlist: InfoPlist = .default,
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        hasTests: Bool = false,
        settings: Settings? = nil,
        dependencies: [TargetDependency] = [],
    ) -> Project {
        let organizationName = "com.pinit.app"
        let bundleId = bundleId ?? "\(organizationName).\(name)"
        
        let mainTarget = Target.target(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: bundleId,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            dependencies: dependencies,
            settings: settings
        )
        
        var targets: [Target] = [mainTarget]
        
        if hasTests {
            let testTarget = Target.target(
                name: "\(name)Tests",
                destinations: destinations,
                product: .unitTests,
                bundleId: "\(bundleId)Tests",
                deploymentTargets: deploymentTargets,
                infoPlist: .default,
                sources: ["Tests/**"],
                dependencies: [.target(name: name)]
            )
            targets.append(testTarget)
        }
        
        return Project(
            name: name,
            targets: targets
        )
    }
}
