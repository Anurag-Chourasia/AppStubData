// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "AppStubData",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppStubData", targets: ["AppStubData"])
    ],
    targets: [
        .target(
            name: "AppStubData",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "AppStubDataTests",
            dependencies: ["AppStubData"]
        )
    ],
    swiftLanguageModes: [.v6]
)
