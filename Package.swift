// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FNLNexus",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "FNLNexus",
            targets: ["FNLNexus"]),
    ],
    targets: [
        .target(
            name: "FNLNexus"),
        .testTarget(
            name: "FNLNexusTests",
            dependencies: ["FNLNexus"]
        ),
    ]
)
