// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "watimetracker",
    products: [
        .library(name: "App", targets: ["App"]),
        .executable(name: "Run", targets: ["Run"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/vapor/engine.git", .upToNextMajor(from: "2.2.2")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.3.0")),
        .package(url: "https://github.com/vapor/leaf-provider.git", .upToNextMajor(from: "1.1.0")),
        .package(url: "https://github.com/vapor/mysql-provider.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/BrettRToomey/Jobs.git", .upToNextMajor(from: "1.1.2"))

    ],
    targets: [
        .target(
            name: "App",
            dependencies: ["Vapor", "LeafProvider", "HTTP", "FluentProvider", "MySQLProvider", "Jobs"],
            exclude: ["Config", "Database", "Public", "Resources"]
        ),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App", "Testing"])
    ]
)

