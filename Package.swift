// swift-tools-version: 5.4

import PackageDescription

let package = Package(
    name: "Swiper",
    platforms: [
        .iOS("17.0"),
    ], products: [
        .library(
            name: "Swiper",
            targets: ["Swiper"]),
    ],
    targets: [
        .target(
            name: "Swiper",
            dependencies: [])
    ]
)
