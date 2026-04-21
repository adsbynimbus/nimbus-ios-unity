# NimbusUnityKit

A Nimbus SDK extension for **Unity Ads bidding and rendering**. It enriches Nimbus ad requests with Unity demand and handles ad rendering through the UnityAds SDK when it wins the auction.

## Versioning

NimbusUnityKit **major versions are kept in sync** with the UnityAds SDK. For example, NimbusUnityKit `4.x.x` depends on UnityAds SDK `4.x.x`.
 
Minor and patch versions are independent — a NimbusUnityKit patch release does not necessarily correspond to a UnityAds SDK patch release, and vice versa.
 
| NimbusUnityKit | UnityAds SDK |
|---|---|
| 4.x.x | 4.x.x |

## Installation

### Swift Package Manager

#### Xcode Project

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL:
   ```
   https://github.com/adsbynimbus/nimbus-ios-unity
   ```
3. Set the dependency rule to **Up to Next Major Version** and enter `4.0.0` as the minimum.
4. Click **Add Package** and select the **NimbusUnityKit** library when prompted.

#### Package.swift

If you're managing dependencies through a `Package.swift` file, add the following:

```swift
dependencies: [
    .package(url: "https://github.com/adsbynimbus/nimbus-ios-unity", from: "4.0.0")
]
```

Then add the product to your target:

```swift
.product(name: "NimbusUnityKit", package: "nimbus-ios-unity")
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'NimbusUnityKit'
```

Then run:

```sh
pod install
```

## Usage
 
Navigate to where you call `Nimbus.initialize` and register the `UnityExtension`:
 
```swift
import NimbusUnityKit
 
Nimbus.initialize(publisher: "<publisher>", apiKey: "<apiKey>") {
    UnityExtension(gameId: "<gameId>")
}
```

If you provide a game ID, Nimbus will automatically initialize the UnityAds SDK.

That's it — Unity Ads is now enabled in all upcoming requests.

## Documentation

- [Nimbus iOS SDK Documentation](https://docs.adsbynimbus.com/docs/sdk/ios) — integration guides, configuration, and API reference.
- [DocC API Reference](https://iosdocs.adsbynimbus.com) — auto-generated documentation for the latest release.

## Sample App

See NimbusUnityKit in action in our public [sample app repository](https://github.com/adsbynimbus/nimbus-ios-sample), which demonstrates end-to-end integration including setup, bid requests, and ad rendering.
