import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.makeModule(
    name: "Presentation",
    product: .framework,
    resources: [
        "Resources/**"
    ],
    hasTests: true,
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": "$(inherited) -ObjC"
        ]
    ),
    dependencies: [
        .project(target: "Domain", path: "../Domain"),
        .external(name: "Expose"),
        .external(name: "FirebaseAuth"),
        .external(name: "FirebaseCore"),
        .external(name: "RxSwift"),
        .external(name: "RxCocoa"),
        .external(name: "RxRelay")
    ]
)
