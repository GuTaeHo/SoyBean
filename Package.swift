// swift-tools-version: 5.10.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SoyBean",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SoyBeanUI",
            targets: ["SoyBeanUI"]),
        .library(
            name: "SoyBeanCore",
            targets: ["SoyBeanCore"])
    ],
    // 프로젝트에 라이브러리를 추가하기 위해서 아래와 같이 작성
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
        .package(url: "https://github.com/devxoul/Then.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        // 타겟에서 라이브러리를 사용하기 위해선 타겟에 추가해줘야함
        .target(
            name: "SoyBeanCore",
            dependencies: [
                .product(name: "Then", package: "Then"),
            ]),
        .target(
            name: "SoyBeanUI",
            dependencies: [
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "Then", package: "Then"),
            ])

    ]
)
