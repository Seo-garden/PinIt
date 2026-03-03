import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.makeModule(
    name: "Presentation",
    product: .framework,
    dependencies: [
        .project(target: "Domain", path: "../Domain"),
        .external(name: "RxSwift"),
        .external(name: "RxCocoa"),
        .external(name: "RxRelay")
    ]
)
