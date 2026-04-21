//
//  NimbusError+Unity.swift
//  NimbusUnityKit
//
//  Created on 2/23/26.
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit

extension NimbusError.Domain {
    static let unity = Self(rawValue: "unity")
}

extension NimbusError {
    static func unity(reason: Reason = .failure, stage: Stage, detail: String? = nil) -> NimbusError {
        NimbusError(reason: reason, domain: .unity, stage: stage, detail: detail)
    }
}
