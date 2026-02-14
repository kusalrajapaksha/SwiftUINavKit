// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftUINavKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftUINavKit",
            targets: ["SwiftUINavKit"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftUINavKit"
        ),
        
    ]
)
