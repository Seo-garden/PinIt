// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        productTypes: [:]
    )
#endif

let package = Package(
    name: "PinItDependencies",
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.10.1"),
        .package(url: "https://github.com/mandooplz/expose.git", exact: "0.1.2")
    ]
)
