//
//  ObjectPreviewViewController.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 14/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import SceneKit
import SceneKit.ModelIO
import UIKit

enum AcceptedFileType : String {
    case obj
    case stl
    case dae
    
    static var acceptedFileTypeExtensions: [String] {
        return [AcceptedFileType.obj, AcceptedFileType.stl, AcceptedFileType.dae].map { $0.rawValue }
    }
}

class ObjectPreviewViewController: UIViewController {

    private var objectScale: Float = 1.0

    var buildingStepPart: BuildingStepService.BuildingStepPart?
    
    @IBOutlet private weak var lblPartDescription: UILabel!
    @IBOutlet private weak var lblPartName: UILabel!
    @IBOutlet private weak var objectPreviewView: SCNView!

    deinit {
        print("deinit object preview")
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupObjectPreview()
        setupAppearance()
    }
    
    @IBAction func btnDismissTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    private func setupAppearance() {
        lblPartName.text = buildingStepPart?.name
        lblPartDescription.text = "Some long part description can go in here.\nWe also support multline descriptions."
    }
    
    private func setupObjectPreview(objectType: AcceptedFileType = .obj) {
        guard
            let buildingStepPath = buildingStepPart,
            let objectScene = SCNScene(named: "\(buildingStepPath.objectName).\(buildingStepPath.objectType.rawValue)")
            else {
                return
        }
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
        mainScene.rootNode.createPlaneNode()
        
        objectPreviewView.scene = mainScene
        objectPreviewView.backgroundColor = UIColor.black
        objectPreviewView.allowsCameraControl = true
        objectPreviewView.autoenablesDefaultLighting = true
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
}
