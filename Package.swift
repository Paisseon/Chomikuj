// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chomikuj",
    platforms: [
        .iOS("13.0"),
        .macOS("10.15")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Chomikuj",
            targets: ["Chomikuj"]),
    ],
    targets: [
        .target(name: "Chomikuj")
    ]
)
