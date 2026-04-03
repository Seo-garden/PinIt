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
            "NSCameraUsageDescription": "기록에 사진을 추가하기 위해 카메라 접근 권한이 필요합니다.",
            "NSPhotoLibraryUsageDescription": "기록에 사진을 불러오기 위해 사진 라이브러리 접근 권한이 필요합니다.",
            "NSPhotoLibraryAddUsageDescription": "촬영한 사진을 사진 라이브러리에 저장하기 위해 권한이 필요합니다.",
            "NSLocationWhenInUseUsageDescription": "사진의 위치 정보를 확인하고 지도에 표시하기 위해 위치 권한이 필요합니다."
        ]
    ),
    sources: ["Sources/**"],
    resources: [
        "Resources/**"
    ],
    dependencies: [
        .project(target: "Core", path: "../Core"),
        .project(target: "Domain", path: "../Domain"),
        .project(target: "Data", path: "../Data"),
        .project(target: "Presentation", path: "../Presentation")
    ]
)
