//
//  StubNimbusUnityRequestInterceptor.swift
//  NimbusUnityKitTests
//
//  Created on 12/14/21.
//  Copyright © 2021 Nimbus Advertising Solutions Inc. All rights reserved.
//

@testable import NimbusUnityKit
import UnityAds

final class MockUnityBridge: UnityRequestBridgeType {
    var _isSupported: Bool = true
    var _isInitialized: Bool = true
    var _token: String? = "token"
    
    var isSupported: Bool { _isSupported }
    var isInitialized: Bool { _isInitialized }
    
    func token(for format: UnityAdsAdFormat) async -> String? {
        _token
    }
}
