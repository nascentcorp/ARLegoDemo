//
//  GeometryNode.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 14/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import SceneKit
import SpriteKit

public enum ShapeType: Int {
    case box
    case sphere
    case pyramid
    case torus
//    case capsule
//    case cylinder
//    case cone
    case tube
    
    static var random: ShapeType {
        let maxValue = tube.rawValue
        let rand = arc4random_uniform(UInt32(maxValue + 1))
        guard let type = ShapeType(rawValue: Int(rand)) else {
            return .box
        }
        return type
    }
}

struct GeometryNodeData {
    let node: SCNNode
    let sprite: SKNode
}

class GeometryNode {

    private let size: CGSize
    private let type: ShapeType
    
    init(with size: CGSize, type: ShapeType = ShapeType.random) {
        self.size = size
        self.type = type
    }

    func create() -> GeometryNodeData {
        let geometry: SCNGeometry
        switch type {
        case .box:
            geometry = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        case .sphere:
            geometry = SCNSphere(radius: 1)
        case .pyramid:
            geometry = SCNPyramid(width: 1, height: 1, length: 1)
        case .torus:
            geometry = SCNTorus(ringRadius: 0.2, pipeRadius: 1)
        case .tube:
            geometry = SCNTube(innerRadius: 0.4, outerRadius: 0.5, height: 1)
        }
        geometry.materials.first?.diffuse.contents = UIColor.random

        let geometryNode = SCNNode(geometry: geometry)

        let helperScene = SCNScene()
        helperScene.rootNode.addChildNode(geometryNode)
        
        let geometrySprite = SK3DNode(viewportSize: size * 0.8)
        geometrySprite.scnScene = helperScene

        return GeometryNodeData(node: geometryNode, sprite: geometrySprite)
    }
}
