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
    
    private func setupObjectPreview() {
        guard let buildingStepPart = buildingStepPart else {
            return
        }
        let partScene = SCNScene.create(fromPart: buildingStepPart)
        let partNode = partScene.rootNode
        partNode.adjustObjectGeometry(objectType: buildingStepPart.objectType)
        
        let camera = SCNCamera()
        camera.zNear = 0.1
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0.3, z: 1.2)
        
        let cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        cameraOrbit.eulerAngles.x -= Float(Double.pi * 0.5 / 4)
        
        let mainScene = SCNScene()
        mainScene.rootNode.addChildNode(partNode)
        mainScene.rootNode.addChildNode(cameraOrbit)
        mainScene.rootNode.createPlaneNode(color: .darkGray)
        
        objectPreviewView.scene = mainScene
        objectPreviewView.backgroundColor = UIColor.white
        objectPreviewView.allowsCameraControl = true
        objectPreviewView.autoenablesDefaultLighting = true
    }
}
