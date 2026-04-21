//
//  UnityInitDelegateWrapper.swift
//  NimbusUnityKit
//
//  Created on 1/27/26.
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import UnityAds
import NimbusKit

final class UnityInitDelegateWrapper: NSObject, UnityAdsInitializationDelegate {
    let continuation: UnsafeContinuation<Void, Never>
    private var didResume = false
    
    init(continuation: UnsafeContinuation<Void, Never>) {
        self.continuation = continuation
    }
    
    func initializationComplete() {
        Nimbus.Log.lifecycle.debug("Unity SDK initialization completed")
        resumeIfNeeded()
    }
    
    func initializationFailed(_ error: UnityAdsInitializationError, withMessage message: String) {
        Nimbus.Log.lifecycle.error("Unity SDK initialization failed: \(message)")
        resumeIfNeeded()
    }
    
    func resumeIfNeeded() {
        guard !didResume else { return }
        
        didResume = true
        continuation.resume()
    }
}
