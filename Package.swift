// swift-tools-version: 5.10.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SoyBean",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8)],
    products: [
        // 여러 product 를 한번에 사용해야하는 경우, `import SoyBean`
        .library(name: "SoyBean",
                 targets: [
                    "SoyBeanCore",
                    "SoyBeanUI",
                    "SoyBeanUtil",
                ]),
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
    ],
    targets: [
        .target(
            name: "SoyBean",
            dependencies: [
                "SoyBeanCore",
                "SoyBeanUI",
                "SoyBeanUtil",
            ]
        ),
        .target(
            name: "SoyBeanCore",
            dependencies: [
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
        ),
        .testTarget(
            name: "SoyBeanTests",
            dependencies: [
                "SoyBeanCore",
                "SoyBeanUtil",
            ]
        )
    ]
)
