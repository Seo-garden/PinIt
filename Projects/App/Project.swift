import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.makeModule(
    name: "App",
    product: .app,
    bundleId: "com.pinit.app",
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
    resources: [
        "Resources/Assets.xcassets"
    ],
    dependencies: [
        .project(target: "Core", path: "../Core"),
        .project(target: "Domain", path: "../Domain"),
        .project(target: "Data", path: "../Data"),
        .project(target: "Presentation", path: "../Presentation")
    ]
)
