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

    private let arEnvironmentService = AREnvironmentService()
    private let buildingStepService = BuildingStepService()

    @IBOutlet private var sceneView: ARSCNView!
    
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
        guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: buildingStepService.catalogName, bundle: nil) else {
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

//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        let results = sceneView.hitTest(touch.location(in: sceneView), types: [.featurePoint])
//
//        guard let hitFeature = results.last else { return }
//        let hitTransform = hitFeature.worldTransform
//        let hitPosition = SCNVector3Make(hitTransform.columns.3.x,
//                                         hitTransform.columns.3.y,
//                                         hitTransform.columns.3.z)
//        guard let shipModelNode = shipModel else {
//            return
//        }
//        sceneView.scene.rootNode.addChildNode(shipModelNode)
//        shipModelNode.position = hitPosition
//    }
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
        objectDetectionCheck(anchor, objectNames: buildingStepService.baseModelScanNames)
        objectDetectionCheck(anchor, objectNames: buildingStepService.partsNames)
    }

    private func objectDetectionCheck(_ anchor: ARAnchor, objectNames: [String]) {
        if
            let objectAnchor = anchor as? ARObjectAnchor,
            let objectName = objectAnchor.referenceObject.name,
            let objectNameIndex = objectNames.firstIndex(where: { $0 == objectName })
        {
            print("|||| Detected object: '\(objectNames[objectNameIndex])' ||||")
            //            if let shipModel = shipModel {
            //                node.addChildNode(shipModel)
            //                shipModel.simdScale = objectAnchor.referenceObject.scale
            //                shipModel.simdPosition = objectAnchor.referenceObject.center
            //            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = sceneView.session.currentFrame else { return }
        updateOnEveryFrame(frame)
    }

    private func updateOnEveryFrame(_ frame: ARFrame) {
        arEnvironmentService.updateWithFrameInfo(frame)
    }
}
