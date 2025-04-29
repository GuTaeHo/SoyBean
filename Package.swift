// swift-tools-version: 5.10.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SoyBean",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
    products: [
        .library(
            name: "SoyBeanCore",
            targets: ["SoyBeanCore"]),
        .library(
            name: "SoyBeanUI",
            targets: ["SoyBeanUI"]),
        .library(
            name: "SoyBeanUtil",
            targets: ["SoyBeanUtil"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
//        .package(url: "https://github.com/devxoul/Then.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "SoyBeanCore",
            dependencies: [
//                .product(name: "Then", package: "Then"),
            ]
        ),
        .target(
            name: "SoyBeanUI",
            dependencies: [
                "SoyBeanCore",
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "SoyBeanUtil",
            dependencies: [
                "SoyBeanCore",
            ]
        )
    ]
)
