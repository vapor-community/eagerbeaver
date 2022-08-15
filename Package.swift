// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "EagerBeaver",
    products: [
        .library(
            name: "EagerBeaver",
            targets: ["EagerBeaver"]),
    ],
    dependencies: [.package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")],
    targets: [
        .target(
            name: "EagerBeaver",
            dependencies: []),
        .testTarget(
            name: "EagerBeaverTests",
            dependencies: ["EagerBeaver"]),
    ]
)
