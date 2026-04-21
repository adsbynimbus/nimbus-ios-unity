//
//  NimbusUnityAdController.swift
//  NimbusUnityKit
//
//  Created on 6/2/21.
//  Copyright © 2021 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit
import UnityAds

final class NimbusUnityAdController: AdController,
                                     @preconcurrency UADSBannerViewDelegate,
                                     @preconcurrency UnityAdsLoadDelegate,
                                     @preconcurrency UnityAdsShowDelegate {
    
    private let adObjectId = UUID().uuidString
    
    override class func setup(
        response: NimbusResponse,
        container: UIView,
        adPresentingViewController: UIViewController?
    ) -> AdController {
        let adController = Self.init(
            response: response,
            isBlocking: false,
            isRewarded: false,
            container: container,
            adPresentingViewController: adPresentingViewController
        )
        
        return adController
    }
    
    override class func setupBlocking(
        response: NimbusResponse,
        isRewarded: Bool,
        adPresentingViewController: UIViewController
    ) -> AdController {
        let adController = Self.init(
            response: response,
            isBlocking: true,
            isRewarded: isRewarded,
            container: nil,
            adPresentingViewController: adPresentingViewController
        )
        
        return adController
    }
    
    override func load() {
        guard let placementId = response.bid.ext?.omp?.buyerPlacementId else {
            sendNimbusError(.unity(reason: .invalidState, stage: .render, detail: "Missing placement id"))
            return
        }
        
        guard let loadOptions = UADSLoadOptions() else {
            sendNimbusError(.unity(stage: .render, detail: "UADSLoadOptions couldn't initialize"))
            return
        }
        
        loadOptions.adMarkup = response.bid.adm
        loadOptions.objectId = adObjectId
        
        switch adRenderType {
        case .banner:            
            let banner = UADSBannerView(placementId: placementId, size: response.bid.size)
            banner.delegate = self
            
            adView.addSubview(banner)
            
            banner.load(with: loadOptions)
        case .interstitial, .rewarded:
            UnityAds.load(placementId, options: loadOptions, loadDelegate: self)
        default:
            sendNimbusError(.unity(reason: .unsupported, stage: .render, detail: "adRenderType: \(adRenderType.rawValue)"))
        }
    }
    
    @MainActor
    private func presentIfNeeded() {
        guard started, adState == .ready else { return }
        
        adState = .resumed
        
        switch adRenderType {
        case .banner: break // no-op, already presented as part of load()
        case .interstitial, .rewarded:
            guard let showOptions = UADSShowOptions() else {
                sendNimbusError(.unity(stage: .render, detail: "UADSShowOptions couldn't initialize"))
                return
            }
            
            guard let placementId = response.bid.ext?.omp?.buyerPlacementId,
                  let adPresentingViewController else {
                sendNimbusError(.unity(reason: .invalidState, stage: .render, detail: "Placement id: \(response.bid.ext?.omp?.buyerPlacementId, default: "nil"), adPresentingViewController: \(adPresentingViewController, default: "nil")"))
                return
            }
            
            showOptions.objectId = adObjectId
            UnityAds.show(adPresentingViewController, placementId: placementId, options: showOptions, showDelegate: self)
        default:
            sendNimbusError(.unity(reason: .invalidState, stage: .render, detail: "Ad \(adRenderType) is invalid and could not be presented."))
        }
    }
    
    private func onUnityAdLoad() {
        sendNimbusEvent(.loaded)
        
        adState = .ready
        presentIfNeeded()
    }
    
    private func onUnityAdShow() {
        sendNimbusEvent(.impression)
    }
    
    private func onUnityAdClick() {
        sendNimbusEvent(.clicked)
    }
    
    // MARK: - AdController
    
    override func onStart() {        
        if adState == .ready {
            presentIfNeeded()
        }
    }
    
    // MARK: - Banner Delegate
    
    func bannerViewDidLoad(_ bannerView: UADSBannerView!) {
        onUnityAdLoad()
    }
    
    func bannerViewDidError(_ bannerView: UADSBannerView!, error: UADSBannerError!) {
        sendNimbusError(.unity(stage: .render, detail: error.localizedDescription))
    }
    
    func bannerViewDidShow(_ bannerView: UADSBannerView!) {
        onUnityAdShow()
    }
    
    func bannerViewDidClick(_ bannerView: UADSBannerView!) {
        onUnityAdClick()
    }
    
    // MARK: - Interstitial/Rewarded Delegate
    
    func unityAdsAdLoaded(_ placementId: String) {
        onUnityAdLoad()
    }
    
    func unityAdsAdFailed(
        toLoad placementId: String,
        withError error: UnityAdsLoadError,
        withMessage message: String
    ) {
        sendNimbusError(.unity(stage: .render, detail: message))
    }
    
    func unityAdsShowComplete(
        _ placementId: String,
        withFinish state: UnityAdsShowCompletionState
    ) {
        sendNimbusEvent(state == .showCompletionStateCompleted ? .completed : .skipped)
        
        destroy()
    }
    
    func unityAdsShowFailed(
        _ placementId: String,
        withError error: UnityAdsShowError,
        withMessage message: String
    ) {
        // Unity seems to throw this error after showing an ad. This is NOT a hard failure
        // so skip sending a Nimbus error for this case
        if error == UnityAdsShowError.showErrorAlreadyShowing {
            Nimbus.Log.ad.debug("UnityAds failed to show: \(message) - error: \(error.rawValue), continuing...")
        } else {
            sendNimbusError(.unity(stage: .render, detail: message))
        }
    }
    
    func unityAdsShowStart(_ placementId: String) {
        onUnityAdShow()
    }
    
    func unityAdsShowClick(_ placementId: String) {
        onUnityAdClick()
    }
}

// Internal: Do NOT implement delegate conformance as separate extensions as the methods won't not be found in runtime when built as a static library
