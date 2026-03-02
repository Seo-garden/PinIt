import ProjectDescription

let settings = Settings.settings(
    base: [
        "SWIFT_VERSION": "6.0",
        "IPHONEOS_DEPLOYMENT_TARGET": "17.0",
    ],
    configurations: [
        .debug(name: "Debug"),
        .release(name: "Release"),
    ],
    defaultSettings: .recommended
)

let project = Project(
    name: "PinItCore",
    settings: settings,
    targets: [
        .target(
            name: "PinItCore",
            destinations: .iOS,
            product: .staticFramework,
            bundleId: "com.pinit.core",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: []
        ),
    ]
)
