//
//  UnityRequestBridge.swift
//  Nimbus
//  Created on 6/4/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import Foundation
import UnityAds

protocol UnityRequestBridgeType: Sendable {
    var isSupported: Bool { get }
    var isInitialized: Bool { get }
    @concurrent func token(for format: UnityAdsAdFormat) async -> String?
}

final class UnityRequestBridge: UnityRequestBridgeType {
    var isSupported: Bool {
        UnityAds.isSupported()
    }
    
    var isInitialized: Bool {
        UnityAds.isInitialized()
    }
    
    @inlinable
    public static func set(coppa: Bool) {
        let metadata = UADSMetaData()
        metadata.setRaw("user.nonbehavioral", value: coppa)
        metadata.commit()
    }
    
    @concurrent func token(for format: UnityAdsAdFormat) async -> String? {
        await withUnsafeContinuation { continuation in
            UnityAds.getToken(with: .init(adFormat: format)) { token in
                continuation.resume(returning: token)
            }
        }
    }
}
