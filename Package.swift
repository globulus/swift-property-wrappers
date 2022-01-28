// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftPropertyWrappers",
    platforms: [
      .iOS(.v13), .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "SwiftPropertyWrappers",
            targets: ["SwiftPropertyWrappers"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SwiftPropertyWrappers",
            dependencies: []),
        .testTarget(
            name: "SwiftPropertyWrappersTests",
            dependencies: ["SwiftPropertyWrappers"]),
    ]
)
