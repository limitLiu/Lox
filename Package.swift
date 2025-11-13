// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Lox",
  platforms: [.macOS(.v10_15)],
  products: [
    .executable(name: "lox", targets: ["Lox"]),
    .library(name: "Core", targets: ["Core"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.2")
  ],
  targets: [
    .executableTarget(
      name: "Lox",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
        "Core",
      ],
    ),
    .target(name: "Core"),
    .testTarget(
      name: "LoxTests",
      dependencies: ["Lox", "Core"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
