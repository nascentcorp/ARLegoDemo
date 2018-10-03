//
//  AREnvironmentService.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 03/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import ARKit

class AREnvironmentService {

    var lightingSufficient = false
    var worldMapStatus: ARFrame.WorldMappingStatus = .notAvailable

    func updateWithFrameInfo(_ frame: ARFrame) {
        // World map status
        if worldMapStatus != frame.worldMappingStatus {
            switch frame.worldMappingStatus {
            case .notAvailable:
                print("WorldMappingStatus - World map not available")
            case .limited:
                print("WorldMappingStatus - Limited world map")
            case .extending:
                print("WorldMappingStatus - World map is being extended")
            case .mapped:
                print("WorldMappingStatus - World map done mapping")
            }
        }
        worldMapStatus = frame.worldMappingStatus
        
        // Lighting
        if let lightEstimate = frame.lightEstimate {
            if lightEstimate.ambientIntensity < 500 {
                print("Too dark for scanning.")
            }
            lightingSufficient = (lightEstimate.ambientIntensity >= 500)
        }
    }
}
