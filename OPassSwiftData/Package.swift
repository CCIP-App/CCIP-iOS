// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OPassSwiftData",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "OPassSwiftData",
            targets: ["OPassSwiftData"]),
    ],
    targets: [
        .target(
            name: "OPassSwiftData",
            path: "."
        )
    ]
)
