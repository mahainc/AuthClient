// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuthClient",
    platforms: [
        .iOS(.v16), .macOS(.v13)
    ],
    products: [
        .singleTargetLibrary("AuthClient"),
        .singleTargetLibrary("AuthClientLive"),
    ],
    dependencies: [
        .package(
            url: "https://github.com/pointfreeco/swift-dependencies.git",
            from: "1.9.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-case-paths.git",
            from: "1.5.0"
        ),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "AuthClient",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "CasePaths", package: "swift-case-paths"),
            ]
        ),
        .target(
            name: "AuthClientLive",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "CasePaths", package: "swift-case-paths"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                "AuthClient",
            ]
        ),
        .testTarget(
            name: "AuthClientTests",
            dependencies: ["AuthClient"]
        ),
    ]
)

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
