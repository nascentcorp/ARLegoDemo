//
//  PartSelectorScene.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 14/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import SpriteKit

class PartSelectorScene: SKScene {

    private let geometryNodeData: [GeometryNodeData]
    private let objectPartSize: CGSize

    private var scrollView: SwiftySKScrollView?
    private var moveableNode: SKNode?

    init(size: CGSize, geometryNodeData: [GeometryNodeData], objectPartSize: CGSize) {
        self.objectPartSize = objectPartSize
        self.geometryNodeData = geometryNodeData
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        view.showsFPS = true

        moveableNode = SKNode()
        guard let moveableNode = moveableNode else {
            fatalError("MoveableNode should exist.")
        }
        addChild(moveableNode)
        
        scrollView = SwiftySKScrollView(frame: frame, moveableNode: moveableNode, direction: .vertical)
        guard let scrollView = scrollView else {
            fatalError("ScrollView should exist.")
        }
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: objectPartSize.height * CGFloat(geometryNodeData.count))
        view.addSubview(scrollView)

        for i in 0..<geometryNodeData.count {
            let currentGeometryNodeData = geometryNodeData[i]
            let sprite = currentGeometryNodeData.sprite

            let containerNode = SKNode()
            containerNode.position = CGPoint(x: frame.midX, y: size.height - objectPartSize.height * 0.5 - CGFloat(i) * objectPartSize.height)
            containerNode.addChild(sprite)
            
            moveableNode.addChild(containerNode)
        }
    }
}
