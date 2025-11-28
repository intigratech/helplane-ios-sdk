// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "HelpLaneSDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "HelpLaneSDK",
            targets: ["HelpLaneSDK"]
        ),
    ],
    targets: [
        .target(
            name: "HelpLaneSDK",
            dependencies: [],
            path: "Sources/HelpLaneSDK"
        ),
    ]
)
