//
//  SCNNode+Extensions.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 15/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import SceneKit

extension SCNNode {

    func createPlaneNode(color: UIColor = .red) {
        let plane = SCNPlane(width: 2.0, height: 2.0)
        plane.widthSegmentCount = 20
        plane.heightSegmentCount = 20
        
        guard let material = plane.firstMaterial else { return }
        material.isDoubleSided = true
        material.diffuse.contents = color
        material.fillMode = .lines
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.transform = SCNMatrix4MakeRotation(Float(Double.pi * 1 / 2), 1.0, 0.0, 0.0)

        addChildNode(planeNode)
    }
}
