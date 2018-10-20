//
//  AREnvironmentService.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 03/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import ARKit

enum LightingStatus {
    case sufficientLight
    case tooDarkForScanning
}

class AREnvironmentService {

    private var lightingStatus: LightingStatus = .sufficientLight
    
    var worldMapStatus: ARFrame.WorldMappingStatus = .notAvailable

    var lightingStatusChanged: ((LightingStatus) -> ())?
    
    lazy var isDeviceARCapable: Bool = {
        return ARObjectScanningConfiguration.isSupported && ARWorldTrackingConfiguration.isSupported
    }()

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
            lightingStatus = (lightEstimate.ambientIntensity >= 500) ? .sufficientLight : .tooDarkForScanning
            if let lightingStatusChanged = lightingStatusChanged {
                lightingStatusChanged(self.lightingStatus)
            }
        }
    }
}
