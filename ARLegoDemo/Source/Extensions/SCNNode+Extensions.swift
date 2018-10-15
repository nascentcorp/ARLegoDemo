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

    func adjustObjectGeometry(objectType: AcceptedFileType) {
        rotateObject(objectType: objectType)
        normalizeObject(objectType: objectType)
        centerObject(objectType: objectType)
    }
    
    private func rotateObject(objectType: AcceptedFileType) {
        if objectType == .obj {
            return
        }
        let previousTransform = self.transform
        let rotation = SCNMatrix4MakeRotation(Float(-2 * Double.pi * 1 / 4), 1.0, 0.0, 0.0)
        self.transform = SCNMatrix4Mult(rotation, previousTransform)
    }
    
    private func centerObject(objectType: AcceptedFileType) {
        let (min, max) = self.boundingBox
        let objectDimensions = max - min
        var rawPivot = max - objectDimensions / 2.0
        if objectType == .obj {
            rawPivot.y = min.y
        }
        else {
            rawPivot.z = min.z
        }
        let pivot = rawPivot.negate()
        let previousTransform = self.transform
        let translation = SCNMatrix4MakeTranslation(pivot.x, pivot.y, pivot.z)
        self.transform = SCNMatrix4Mult(translation, previousTransform)
    }
    
    private func normalizeObject(objectType: AcceptedFileType) {
        let (min, max) = self.boundingBox
        let objectDimensions = max - min
        let objectLength = objectDimensions.length()
        let objectScale = 1.0 / objectLength
        let previousTransform = self.transform
        let scale = SCNMatrix4MakeScale(objectScale, objectScale, objectScale)
        self.transform = SCNMatrix4Mult(scale, previousTransform)
    }
}
