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
    name: "PinItTests",
    settings: settings,
    targets: [
        .target(
            name: "PinItTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.pinit.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [
                .project(target: "PinItCore", path: "../PinItCore"),
                .project(target: "PinItApp", path: "../PinItApp"),
            ]
        ),
    ]
)
