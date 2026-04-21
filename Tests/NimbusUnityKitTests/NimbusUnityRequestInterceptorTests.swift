//
//  NimbusUnityRequestInterceptor.swift
//  NimbusUnityKitTests
//
//  Created on 12/13/21.
//  Copyright © 2021 Nimbus Advertising Solutions Inc. All rights reserved.
//

@testable import NimbusUnityKit
@testable import NimbusKit
import UnityAds
import Testing

@Suite("Unity interceptor tests") struct NimbusUnityRequestInterceptorTests {
    let bridge: MockUnityBridge
    let interceptor: NimbusUnityRequestInterceptor
    
    init() {
        bridge = MockUnityBridge()
        interceptor = NimbusUnityRequestInterceptor(bridge: bridge)
    }
    
    @Test func unityTokenIsReturned() async throws {
        let ad = try await Nimbus.rewardedAd(position: "test")
        let info = try await NimbusRequest(from: ad.adRequest!.request)
        let deltas = try await interceptor.modifyRequest(request: info)
        
        let actualToken = await bridge.token(for: .banner)
        
        #expect(deltas.count == 1)
        #expect(deltas[0].target == .user)
        #expect(deltas[0].key == "unity_buyeruid")
        #expect(deltas[0].value as? String == actualToken)
    }
    
    @Test func throwsWhenUnityIsNotInitialized() async throws {
        bridge._isInitialized = false
        let ad = try await Nimbus.rewardedAd(position: "test")
        
        await #expect(throws: NimbusError.self) {
            let info = try await NimbusRequest(from: ad.adRequest!.request)
            _ = try await interceptor.modifyRequest(request: info)
        }
    }
    
    @Test func throwsWhenUnityIsNotSupported() async throws {
        bridge._isSupported = false
        let ad = try await Nimbus.rewardedAd(position: "test")
        
        let error = await #expect(throws: NimbusError.self) {
            let info = try await NimbusRequest(from: ad.adRequest!.request)
            _ = try await interceptor.modifyRequest(request: info)
        }
        #expect(error!.domain == .unity)
        #expect(error?.reason == .unsupported)
        #expect(error?.stage == .request)
        #expect(error?.detail == "This device is not supported")
    }
    
    @Test func throwsWhenUnityTokenIsNotAvailable() async throws {
        bridge._token = nil
        let ad = try await Nimbus.rewardedAd(position: "test")
        
        let error = await #expect(throws: NimbusError.self) {
            let info = try await NimbusRequest(from: ad.adRequest!.request)
            _ = try await interceptor.modifyRequest(request: info)
        }
        
        #expect(error!.domain == .unity)
        #expect(error?.reason == .failure)
        #expect(error?.stage == .request)
        #expect(error?.detail == "Couldn't fetch bid token")
    }
    
    @Test func throwsWhenRequestIsNative() async throws {
        let ad = try await Nimbus.inlineAd(position: "test") {
            native()
        }
        let error = await #expect(throws: NimbusError.self) {
            let info = try await NimbusRequest(from: ad.adRequest!.request)
            _ = try await interceptor.modifyRequest(request: info)
        }
        
        #expect(error!.domain == .unity)
        #expect(error?.reason == .unsupported)
        #expect(error?.stage == .request)
        #expect(error?.detail == "Unsupported ad unit type: native")
    }
    
    @MainActor
    @Test func unityTokenGetsInsertedIntoRequest() async throws {
        let ad = try Nimbus.rewardedAd(position: "test")
        ad.adRequest!.request.interceptors = [interceptor]
        
        try await ad.adRequest!.request.modifyRequestWithExtras(
            configuration: Nimbus.configuration,
            vendorId: "",
            appVersion: "1.0.0"
        )
        
        #expect(ad.adRequest!.request.user?.ext?.extras["unity_buyeruid"] as? String == "token")
    }
}
