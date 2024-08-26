// swift-tools-version: 5.9

import CompilerPluginSupport
import Foundation
import PackageDescription

let package = Package(
    name: "AppRemoteConfigService",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8), .macCatalyst(.v15)],
    products: [
        .library(
            name: "AppRemoteConfigServiceMacros",
            targets: ["AppRemoteConfigServiceMacros"]
        ),
        .library(
            name: "AppRemoteConfigService",
            targets: ["AppRemoteConfigService"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/egeniq/app-remote-config", from: "0.2.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0"..<"600.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.2.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.0.0"),
        .package(url: "https://github.com/tgrapperon/swift-dependencies-additions", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "AppRemoteConfigServiceMacros",
            dependencies: [
                "AppRemoteConfigServiceMacrosPlugin",
                .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
            ]
        ),
        .macro(
            name: "AppRemoteConfigServiceMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "AppRemoteConfigMacrosPluginTests",
            dependencies: [
                "AppRemoteConfigServiceMacrosPlugin",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
        .target(
            name: "AppRemoteConfigService",
            dependencies: [
                .product(name: "AppRemoteConfig", package: "app-remote-config"),
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesAdditions", package: "swift-dependencies-additions")
            ]),
        .testTarget(
            name: "AppRemoteConfigServiceTests",
            dependencies: [
                "AppRemoteConfigService"
            ]
        )
    ]
)
