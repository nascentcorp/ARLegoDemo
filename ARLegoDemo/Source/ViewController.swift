//
//  ViewController.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 28/09/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import ARKit
import SceneKit
import SceneKit.ModelIO
import UIKit

enum AcceptedFileType : String {
    case obj
    case stl
    
    static var acceptedFileTypeExtensions: [String] {
        return [AcceptedFileType.obj, AcceptedFileType.stl].map { $0.rawValue }
    }
}

class ViewController: UIViewController {

    private let arEnvironmentService = AREnvironmentService()
    private let buildingStepService = BuildingStepService()

    private var objectScale: Float = 1.0

    @IBOutlet private weak var baseObjectPreviewView: SCNView!
    @IBOutlet private weak var baseObjectPreviewContainer: UIView!
    @IBOutlet private weak var btnMaximizeBaseObjectPreview: UIButton!
    @IBOutlet private weak var btnMinimizeBaseObjectPreview: UIButton!
    @IBOutlet private var cnBaseObjectPreviewTopDistance: NSLayoutConstraint!
    @IBOutlet private var cnBaseObjectPreviewViewHeight: NSLayoutConstraint!
    @IBOutlet private var cnBaseObjectPreviewViewWidth: NSLayoutConstraint!
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

        setupObjectPreview()
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

    @IBAction func btnMaximizeObjectPreviewTapped(_ sender: Any) {
        maximizeBaseObjectPreviewWorker(maximize: true)
    }
    
    @IBAction func btnMinimizeObjectPreviewTapped(_ sender: Any) {
        maximizeBaseObjectPreviewWorker(maximize: false)
    }
    
    private func maximizeBaseObjectPreviewWorker(maximize: Bool) {
        btnMaximizeBaseObjectPreview.isHidden = maximize
        btnMinimizeBaseObjectPreview.isHidden = !maximize

        cnBaseObjectPreviewViewHeight.isActive = !maximize
        cnBaseObjectPreviewViewWidth.isActive = !maximize
        cnBaseObjectPreviewTopDistance.isActive = !maximize
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupObjectPreview(objectType: AcceptedFileType = .obj) {
        guard let objectPath = Bundle.main.path(forResource: "statue", ofType: objectType.rawValue) else { return }
        let objectURL = URL(fileURLWithPath: objectPath)
        let asset = MDLAsset(url: objectURL)
        let objectScene = SCNScene(mdlAsset: asset)
        let objectNode = objectScene.rootNode
        adjustObjectGeometry(inNode: objectNode, objectType: objectType)

        let camera = SCNCamera()
        camera.zNear = 0.1
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0.3, z: 1.2)
        
        let cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        cameraOrbit.eulerAngles.x -= Float(Double.pi * 0.5 / 4)
        
        let mainScene = SCNScene()
        mainScene.rootNode.addChildNode(objectNode)
        mainScene.rootNode.addChildNode(cameraOrbit)
        mainScene.rootNode.addChildNode(createPlaneNode())
        
        baseObjectPreviewView.scene = mainScene
        baseObjectPreviewView.backgroundColor = UIColor.black
        baseObjectPreviewView.allowsCameraControl = true
        baseObjectPreviewView.autoenablesDefaultLighting = true
    }

    private func adjustObjectGeometry(inNode node: SCNNode?, objectType: AcceptedFileType) {
        guard let node = node else { return }
        rotateObject(inNode: node, objectType: objectType)
        scaleObject(inNode: node, objectType: objectType)
        centerObject(inNode: node, objectType: objectType)
    }
    
    private func rotateObject(inNode node: SCNNode, objectType: AcceptedFileType) {
        if objectType == .obj {
            return
        }
        let previousTransform = node.transform
        let rotation = SCNMatrix4MakeRotation(Float(-2 * Double.pi * 1 / 4), 1.0, 0.0, 0.0)
        node.transform = SCNMatrix4Mult(rotation, previousTransform)
    }
    
    private func centerObject(inNode node: SCNNode, objectType: AcceptedFileType) {
        let (min, max) = node.boundingBox
        let objectDimensions = max - min
        var rawPivot = max - objectDimensions / 2.0
        if objectType == .obj {
            rawPivot.y = min.y
        }
        else {
            rawPivot.z = min.z
        }
        let pivot = rawPivot.negate()
        let previousTransform = node.transform
        let translation = SCNMatrix4MakeTranslation(pivot.x, pivot.y, pivot.z)
        node.transform = SCNMatrix4Mult(translation, previousTransform)
    }
    
    private func scaleObject(inNode node: SCNNode, objectType: AcceptedFileType) {
        let (min, max) = node.boundingBox
        let objectDimensions = max - min
        let objectLength = objectDimensions.length()
        objectScale = 1.0 / objectLength
        let previousTransform = node.transform
        let scale = SCNMatrix4MakeScale(objectScale, objectScale, objectScale)
        node.transform = SCNMatrix4Mult(scale, previousTransform)
    }

    private func createPlaneNode() -> SCNNode {
        let plane = SCNPlane(width: 2.0, height: 2.0)
        plane.widthSegmentCount = 20
        plane.heightSegmentCount = 20
        
        guard let material = plane.firstMaterial else { return SCNNode() }
        material.isDoubleSided = true
        material.diffuse.contents = UIColor.red
        material.fillMode = .lines
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.transform = SCNMatrix4MakeRotation(Float(Double.pi * 1 / 2), 1.0, 0.0, 0.0)
        return planeNode
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
