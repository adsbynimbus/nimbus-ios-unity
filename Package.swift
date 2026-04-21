// swift-tools-version: 6.1

import PackageDescription

var package = Package(
    name: "NimbusUnityKit",
    platforms: [.iOS(.v13)],
    products: [
        .library(
           name: "NimbusUnityKit",
           targets: ["NimbusUnityKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/adsbynimbus/swift-package-unityads", from: "4.15.1"),
    ],
    targets: [
        .target(
            name: "NimbusUnityKit",
            dependencies: [
                .product(name: "NimbusKit", package: "nimbus-ios-sdk"),
                .product(name: "UnityAds", package: "swift-package-unityads")
            ]
        ),
        .testTarget(
            name: "NimbusUnityKitTests",
            dependencies: ["NimbusUnityKit"],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)

package.dependencies.append(.package(url: "https://github.com/adsbynimbus/nimbus-ios-sdk", from: "3.0.0-rc.1"))
