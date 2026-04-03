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
        .package(url: "https://github.com/mandooplz/expose.git", from: "0.1.2"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "12.11.0"),
//        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.9.1")
    ]
)
