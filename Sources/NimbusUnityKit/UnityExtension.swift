//
//  UnityExtension.swift
//  Nimbus
//  Created on 4/2/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit
import UnityAds

/// Nimbus extension for UnityAds.
///
/// Enables UnityAds rendering when included in `Nimbus.initialize(...)`.
/// Supports dynamic enable/disable at runtime.
///
/// ### Notes:
///   - Instantiate within the `Nimbus.initialize` block; the extension is installed and enabled automatically.
///   - Disable rendering with `UnityExtension.disable()`.
///   - Re-enable rendering with `UnityExtension.enable()`.
public struct UnityExtension: NimbusRequestExtension, NimbusRenderExtension {
    @_documentation(visibility: internal)
    public var interceptor: any NimbusRequest.Interceptor
    
    @_documentation(visibility: internal)
    public var enabled = true
    
    @_documentation(visibility: internal)
    public var network: String { "unity" }
    
    @_documentation(visibility: internal)
    public var controllerType: AdController.Type { NimbusUnityAdController.self }
    
    /// Creates a UnityAds extension.
    ///
    /// - Parameter gameId: UnityAds Game ID. If provided, Nimbus initializes the Unity Ads SDK automatically.
    ///
    /// ##### Usage
    /// ```swift
    /// Nimbus.initialize(publisher: "<publisher>", apiKey: "<apiKey>") {
    ///     UnityExtension(gameId: "<gameId>") // Enables UnityAds rendering
    /// }
    /// ```
    public init(gameId: String? = nil) {
        self.interceptor = NimbusUnityRequestInterceptor()
        
        guard let gameId else {
            Nimbus.Log.lifecycle.debug("Skipping Unity Ads SDK initialization, gameId was not provided")
            return
        }
        
        Task { await Self.initializeUnityAds(gameId: gameId) }
    }
    
    @_documentation(visibility: internal)
    public func coppaDidChange(coppa: Bool) {
        UnityRequestBridge.set(coppa: coppa)
    }
    
    private static func initializeUnityAds(gameId: String) async {
        UnityExtension.configureMetadata()
        
        #if DEBUG
        UnityAds.setDebugMode(true)
        #endif
        
        let testMode = await Nimbus.configuration.testMode
        var delegate: UnityInitDelegateWrapper?
        
        await withUnsafeContinuation { continuation in
            delegate = UnityInitDelegateWrapper(continuation: continuation)
            UnityAds.initialize(gameId, testMode: testMode, initializationDelegate: delegate)
        }
    }
    
    /// Configures Unity Ads metadata required for header-bidding flows.
    ///
    /// Call this method **only if your app initializes Unity Ads directly** (that is, you call
    /// ``UnityAds.initialize(_:testMode:initializationDelegate:)`` yourself).
    ///
    /// If you pass a `gameId` to ``UnityExtension(gameId:)``, Nimbus will initialize Unity Ads for you
    /// and apply this configuration automatically.
    ///
    /// - Important: Call this method *before* initializing Unity Ads. If you call it after initialization,
    ///   Unity Ads may ignore the setting for the current session.
    static func configureMetadata() {
        let metadata = UADSMetaData(category: "headerbidding")
        metadata?.setRaw("mode", value: "enabled")
        metadata?.commit()
    }
}
