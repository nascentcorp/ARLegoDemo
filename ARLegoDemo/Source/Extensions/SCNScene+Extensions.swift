//
//  SCNScene+Extensions.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 15/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import SceneKit
import SceneKit.ModelIO

extension SCNScene {

    static func create(fromPart part: BuildingStepService.BuildingStepPart) -> SCNScene {
        guard let objectScene = SCNScene(named: "\(part.objectName).\(part.objectType.rawValue)") else {
            assertionFailure("Scene should be able to be created from the pre-built part. Check if filename/type is set correctly.")
            return SCNScene()
        }
        return objectScene
    }
}
