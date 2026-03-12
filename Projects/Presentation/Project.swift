import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.makeModule(
    name: "Presentation",
    product: .framework,
    hasTests: true,
    dependencies: [
        .project(target: "Domain", path: "../Domain"),
        .external(name: "Expose"),
        .external(name: "RxSwift"),
        .external(name: "RxCocoa"),
        .external(name: "RxRelay")
    ]
)
