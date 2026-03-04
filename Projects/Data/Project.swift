import ProjectDescriptionHelpers
import ProjectDescription

let project = Project.makeModule(
    name: "Data",
    product: .framework,
    dependencies: [
        .project(target: "Domain", path: "../Domain")
    ]
)
