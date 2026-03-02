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
    name: "PinItApp",
    settings: settings,
    targets: [
        .target(
            name: "PinItApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.pinit.app",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [:],
                    "UIApplicationSceneManifest": [
                        "UIApplicationSupportsMultipleScenes": false,
                        "UISceneConfigurations": [
                            "UIWindowSceneSessionRoleApplication": [
                                [
                                    "UISceneConfigurationName": "Default Configuration",
                                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                                ],
                            ],
                        ],
                    ],
                ]
            ),
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .project(target: "PinItCore", path: "../PinItCore"),
                .external(name: "RxSwift"),
                .external(name: "RxCocoa"),
            ]
        ),
    ]
)
