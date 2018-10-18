//
//  SCNNode+Extensions.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 15/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import SceneKit

extension SCNNode {

//    func createIconNode(image: UIImage, position: CGPoint) {
//        let cylinderNode = SCNCylinder(radius: 0.2, height: 3)
//    }

    func addActionNode(image: UIImage, eyeNode: SCNNode?) {
        var actionsNode = childNodes.filter({ $0.name == PartNodeKeys.actionsNode.rawValue }).first
        if actionsNode == nil {
            actionsNode = SCNNode()
        }
        guard let actionsNodeContainer = actionsNode else {
            fatalError("This should not happen.")
        }

        let box = SCNBox(width: 0.5, height: 0.5, length: 0.1, chamferRadius: 0)
        box.materials.first?.diffuse.contents = UIColor.red
//        box.materials.first?.diffuse.contents = image
        let boxNode = SCNNode(geometry: box)

        if let eyeNode = eyeNode {
            let lookAtConstraint = SCNLookAtConstraint(target: eyeNode)
            boxNode.constraints = [lookAtConstraint]
        }
        actionsNodeContainer.addChildNode(boxNode)

        actionsNodeContainer.position = boundingSphere.center + SCNVector3(0.0, boundingSphere.radius + 0.01, 0.0)
        addChildNode(actionsNodeContainer)
    }
    
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

    func adjustObjectGeometry(objectType: AcceptedFileType, scale: Float = 1.0) {
        rotateObject(objectType: objectType)
        normalizeObject(objectType: objectType, scale: scale)
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
    
    private func normalizeObject(objectType: AcceptedFileType, scale: Float) {
        let (min, max) = self.boundingBox
        let objectDimensions = max - min
        let objectLength = objectDimensions.length()
        let objectScale = scale / objectLength
        let previousTransform = self.transform
        let scale = SCNMatrix4MakeScale(objectScale, objectScale, objectScale)
        self.transform = SCNMatrix4Mult(scale, previousTransform)
    }
}
