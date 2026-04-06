import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.makeModule(
    name: "Data",
    product: .framework,
    resources: [
        "Resources/**"
    ],
    settings: .settings(
        base: [
            "OTHER_LDFLAGS": "$(inherited) -ObjC"
        ]
    ),
    dependencies: [
        .project(target: "Domain", path: "../Domain"),
        .external(name: "FirebaseAuth"),
        .external(name: "FirebaseCore"),
        .external(name: "RxSwift")
    ]
)
