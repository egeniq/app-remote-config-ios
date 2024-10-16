# AppRemoteConfig for iOS

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fegeniq%2Fapp-remote-config-ios%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/egeniq/app-remote-config-ios) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fegeniq%2Fapp-remote-config-ios%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/egeniq/app-remote-config-ios)

Configure apps remotely: A simple but effective way to manage apps remotely.

Create a simple configuration file that is easy to maintain and host, yet provides important flexibility to specify settings based on your needs.

General info about AppRemoteConfig can be found [here](https://github.com/egeniq/app-remote-config).

## Schema

The JSON/YAML schema is defined [here](https://raw.githubusercontent.com/egeniq/app-remote-config/main/Schema/appremoteconfig.schema.json).

## CLI Utility

Use the `care` CLI utility to initialize, verify, resolve and prepare configuration files.

To install use:

    brew install egeniq/app-utilities/care

## Multiplatform

### Swift

Import the package in your `Package.swift` file:

    .package(url: "https://github.com/egeniq/app-remote-config-ios", from: "0.5.0"),

Then a good approach is to create your own `AppRemoteConfigClient`.

    // App Remote Config
    .target(
        name: "AppRemoteConfigClient",
        dependencies: [
            .product(name: "AppRemoteConfigService", package: "app-remote-config-ios"),
            .product(name: "AppRemoteConfigServiceMacros", package: "app-remote-config-ios"),
            .product(name: "Dependencies", package: "swift-dependencies"),
            .product(name: "DependenciesAdditions", package: "swift-dependencies-additions"),
            .product(name: "DependenciesMacros", package: "swift-dependencies"),
            .product(name: "Perception", package: "swift-perception")
        ]
    )
        
Using these dependencies:

    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
    .package(url: "https://github.com/pointfreeco/swift-perception", from: "1.0.0"),
    .package(url: "https://github.com/tgrapperon/swift-dependencies-additions", from: "1.0.0")
     
Then your `AppRemoteConfigClient.swift` is something like this:
        
    import AppRemoteConfigService
    import AppRemoteConfigServiceMacros
    import Dependencies
    import DependenciesMacros
    import Foundation
    import Perception

    @AppRemoteConfigValues @Perceptible @MainActor
    public class Values {
        public private(set) var updateRecommended: Bool = false
        public private(set) var updateRequired: Bool = false
    }

    @DependencyClient
    public struct AppRemoteConfigClient: Sendable {
        public var values: @Sendable @MainActor () -> Values = { Values() }
    }

    extension DependencyValues {
        public var configClient: AppRemoteConfigClient {
            get { self[AppRemoteConfigClient.self] }
            set { self[AppRemoteConfigClient.self] = newValue }
        }
    }

    extension AppRemoteConfigClient: TestDependencyKey {
        public static let testValue = Self()
    }
    
    extension AppRemoteConfigClient: DependencyKey {
        public static let liveValue = {
            let live = LockIsolated<LiveMainActorAppRemoteConfigClient?>(nil)
            return AppRemoteConfigClient(
                values: {
                    if live.value == nil {
                        let dependency = LiveMainActorAppRemoteConfigClient()
                        live.setValue(dependency)
                    }
                    return live.value!.values
                }
            )
        }()
    }

    // This is used to workaround the error:
    // Main actor-isolated static property 'liveValue' cannot be used to satisfy nonisolated protocol requirement.
    @MainActor
    private class LiveMainActorAppRemoteConfigClient {
        fileprivate let values: Values
        private let service: AppRemoteConfigService
        
        init() {
            let url = URL(string: "https://www.example.com/config.json")!
            let bundledConfigURL = Bundle.main.url(forResource: "appconfig", withExtension: "json")
            values = Values()
            service = AppRemoteConfigService(url: url, publicKey: nil, bundledConfigURL: bundledConfigURL, bundleIdentifier: Bundle.main.bundleIdentifier ?? "Sample", apply: values.apply(settings:))
        }
    }


### Android

Support for Android can be found [here](https://github.com/egeniq/app-remote-config-android).
