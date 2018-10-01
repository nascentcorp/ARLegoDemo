//
//  ViewController.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 28/09/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController {

    private var lightingSufficient = false
    private var worldMapStatus: ARFrame.WorldMappingStatus = .notAvailable
    
    @IBOutlet var sceneView: ARSCNView!
    
    var shipModel: SCNNode? {
        let shipNode = sceneView.scene.rootNode.childNode(withName: "ship", recursively: false)?.childNode(withName: "shipMesh", recursively: false)
        return shipNode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: "test", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        configuration.detectionObjects = referenceObjects
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

extension ViewController: ARSCNViewDelegate {
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }


    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if
            let objectAnchor = anchor as? ARObjectAnchor,
            let objectName = objectAnchor.referenceObject.name,
            objectName == "babuska"
        {
            if let shipModel = shipModel {
                node.addChildNode(shipModel)
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = sceneView.session.currentFrame else { return }
        updateOnEveryFrame(frame)
    }

    private func updateOnEveryFrame(_ frame: ARFrame) {
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
