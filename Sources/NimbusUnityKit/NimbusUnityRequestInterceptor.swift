//
//  NimbusUnityRequestInterceptor.swift
//  NimbusUnityKit
//
//  Created on 6/2/21.
//  Copyright © 2021 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit
import UnityAds

final class NimbusUnityRequestInterceptor: Sendable {
    
    private let bridge: UnityRequestBridgeType
    
    init(bridge: UnityRequestBridgeType = UnityRequestBridge()) {
        self.bridge = bridge
    }
}

extension NimbusUnityRequestInterceptor: NimbusRequest.Interceptor {
    
    public func modifyRequest(request: NimbusRequest) async throws -> [NimbusRequest.Delta] {
        guard bridge.isInitialized else {
            throw NimbusError.unity(reason: .invalidState, stage: .request, detail: "Not initialized before request")
        }
        guard bridge.isSupported else {
            throw NimbusError.unity(reason: .unsupported, stage: .request, detail: "This device is not supported")
        }
        
        guard let adFormat = request.adUnitType.unityAdFormat else {
            throw NimbusError.unity(reason: .unsupported, stage: .request, detail: "Unsupported ad unit type: \(request.adUnitType)")
        }
        
        guard let token = await bridge.token(for: adFormat) else {
            throw NimbusError.unity(stage: .request, detail: "Couldn't fetch bid token")
        }
        
        return [.init(target: .user, key: "unity_buyeruid", value: token)]
    }
}

fileprivate extension AdUnitType {
    var unityAdFormat: UnityAdsAdFormat? {
        switch self {
        case .inline, .dynamic: .banner
        case .interstitial: .interstitial
        case .rewarded: .rewarded
        default: nil
        }
    }
}
