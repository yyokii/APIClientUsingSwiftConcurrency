// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppMain",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AppMain",
            targets: ["Home"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GithubAPIClient",
            dependencies: []),
        .target(
            name: "Home",
            dependencies: ["GithubAPIClient"]),
        
        // Test
        .testTarget(
            name: "AppMainTests",
            dependencies: ["Home"]),
    ]
)
