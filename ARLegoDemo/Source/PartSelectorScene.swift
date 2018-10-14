//
//  PartSelectorScene.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 14/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import SpriteKit

class PartSelectorScene: SKScene {

    private let numberOfObjectParts: Int
    private let objectPartSize = CGSize(width: 130, height: 130)

    private var scrollView: SwiftySKScrollView?
    private var moveableNode: SKSpriteNode?

    init(size: CGSize, numberOfObjectParts: Int) {
        self.numberOfObjectParts = numberOfObjectParts
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)

        moveableNode = SKSpriteNode(color: .clear, size: frame.size)
        guard let moveableNode = moveableNode else {
            fatalError("MoveableNode should exist.")
        }
        addChild(moveableNode)
        
        scrollView = SwiftySKScrollView(frame: frame, moveableNode: moveableNode, direction: .vertical)
        guard let scrollView = scrollView else {
            fatalError("ScrollView should exist.")
        }
        scrollView.contentSize = CGSize(width: scrollView.bounds.width, height: objectPartSize.height * CGFloat(numberOfObjectParts))
        view.addSubview(scrollView)
        
        let page1ScrollView = SKSpriteNode(color: .clear, size: frame.size)
        page1ScrollView.position = CGPoint(x: frame.midX, y: frame.midY)
        moveableNode.addChild(page1ScrollView)
        
        let page2ScrollView = SKSpriteNode(color: .clear, size: frame.size)
        page2ScrollView.position = CGPoint(x: frame.midX, y: frame.midY - frame.height)
        moveableNode.addChild(page2ScrollView)
        
        let page3ScrollView = SKSpriteNode(color: .clear, size: frame.size)
        page3ScrollView.position = CGPoint(x: frame.midX, y: frame.midY - (frame.height * 2))
        moveableNode.addChild(page3ScrollView)
        
        /// Test sprites page 1
        let sprite1Page1 = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        sprite1Page1.position = CGPoint(x: 0, y: 0)
        page1ScrollView.addChild(sprite1Page1)
        
        let sprite2Page1 = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        sprite2Page1.position = CGPoint(x: sprite1Page1.position.x, y: sprite1Page1.position.y - sprite2Page1.size.height * 1.5)
        sprite1Page1.addChild(sprite2Page1)
        
        /// Test sprites page 2
        let sprite1Page2 = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        sprite1Page2.position = CGPoint(x: 0, y: 0)
        page2ScrollView.addChild(sprite1Page2)
        
        let sprite2Page2 = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        sprite2Page2.position = CGPoint(x: sprite1Page2.position.x, y: sprite1Page2.position.y - (sprite2Page2.size.height * 1.5))
        sprite1Page2.addChild(sprite2Page2)
        
        /// Test sprites page 3
        let sprite1Page3 = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        sprite1Page3.position = CGPoint(x: 0, y: 0)
        page3ScrollView.addChild(sprite1Page3)
        
        let sprite2Page3 = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        sprite2Page3.position = CGPoint(x: sprite1Page3.position.x, y: sprite1Page3.position.y - (sprite2Page3.size.height * 1.5))
        sprite1Page3.addChild(sprite2Page3)
    }
}
