//
//  ViewController.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 28/09/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import ARKit
import UIKit

class PartCell: UICollectionViewCell {

    @IBOutlet private weak var ivPartImage: UIImageView!
    @IBOutlet private weak var lblPartName: UILabel!
    
    func setup(with part: BuildingStepService.BuildingStepPart) {
        lblPartName.text = part.name
        ivPartImage.image = UIImage(named: part.imageName)
    }
}

class ViewController: UIViewController {

    private let arEnvironmentService = AREnvironmentService()
    private let buildingStepService = BuildingStepService()

    private let cellName = String(describing: PartCell.self)
    private let objectPartSize = CGSize(width: 130, height: 130)
    
    @IBOutlet private weak var cvParts: UICollectionView!
    @IBOutlet private weak var ivBaseObjectImage: UIImageView!
    @IBOutlet private weak var lblBaseObjectName: UILabel!
    @IBOutlet private weak var sgmSceneSwitch: UISegmentedControl!
    @IBOutlet private weak var view3DScene: SCNView!
    @IBOutlet private var viewARScene: ARSCNView!
    
    var shipModel: SCNNode? {
        let shipNode = viewARScene.scene.rootNode.childNode(withName: "ship", recursively: false)?.childNode(withName: "shipMesh", recursively: false)
        return shipNode
    }
    
    lazy var isDeviceARCapable: Bool = {
        return ARObjectScanningConfiguration.isSupported && ARWorldTrackingConfiguration.isSupported
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isDeviceARCapable {
            setupARScene()
        }
        setup3DScene()
        setupAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isDeviceARCapable {
            let configuration = ARWorldTrackingConfiguration()
            guard let referenceObjects = ARReferenceObject.referenceObjects(inGroupNamed: buildingStepService.arCatalogName, bundle: nil) else {
                fatalError("Missing expected asset catalog resources.")
            }
            configuration.detectionObjects = referenceObjects
            viewARScene.session.run(configuration)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isDeviceARCapable {
            viewARScene.session.pause()
        }
    }
    
    @IBAction func btnBaseObjectPreviewTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let objectPreviewViewController = storyboard.instantiateViewController(withIdentifier: "ObjectPreviewViewController") as? ObjectPreviewViewController else {
            return
        }
        objectPreviewViewController.buildingStepPart = buildingStepService.baseModelPart
        present(objectPreviewViewController, animated: true)
    }

    @IBAction func btnSceneSwitchTapped(_ sender: UISegmentedControl) {
        view3DScene.isHidden = (sender.selectedSegmentIndex == 0)
        viewARScene.isHidden = (sender.selectedSegmentIndex == 1)
    }
    
    private func setupAppearance() {
        lblBaseObjectName.text = buildingStepService.baseModelPart.name
        ivBaseObjectImage.image = UIImage(named: buildingStepService.baseModelPart.imageName)
        
        if !isDeviceARCapable {
            sgmSceneSwitch.isHidden = true
            view3DScene.isHidden = false
            viewARScene.isHidden = true
        }
    }
    
    private func setupARScene() {
        // TODO: See if we can initialize this with an empty scene.
        let scene = SCNScene(named: "art.scnassets/ARLegoDemo.scn")!

        addParts(toScene: scene)

        viewARScene.scene = scene
        viewARScene.delegate = self
        viewARScene.automaticallyUpdatesLighting = true
    }

    private func setup3DScene() {
        let camera = SCNCamera()
        camera.zNear = 0.1
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0.3, z: 1.2)

        let cameraOrbit = SCNNode()
        cameraOrbit.addChildNode(cameraNode)
        cameraOrbit.eulerAngles.x -= Float(Double.pi * 0.5 / 4)
        
        let mainScene = SCNScene()
        mainScene.rootNode.addChildNode(cameraOrbit)
        mainScene.rootNode.createPlaneNode(color: .yellow)
        
        addParts(toScene: mainScene)
        
        view3DScene.scene = mainScene
        view3DScene.backgroundColor = UIColor.black
        view3DScene.allowsCameraControl = true
        view3DScene.autoenablesDefaultLighting = true
    }

    private func addParts(toScene scene: SCNScene) {
        addBaseObjectPart(toScene: scene)
    }

    private func addBaseObjectPart(toScene scene: SCNScene) {
        addPartWorker(buildingStepService.baseModelPart, toScene: scene)
    }

    private func addBasePart(toScene scene: SCNScene) {
        buildingStepService.parts.forEach({ part in
            self.addPartWorker(buildingStepService.baseModelPart, toScene: scene)
        })
    }
    
    private func addPartWorker(_ part: BuildingStepService.BuildingStepPart, toScene scene: SCNScene) {
        
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
        guard
            let configuration = session.configuration,
            isDeviceARCapable
            else {
                return
        }
        viewARScene.session.run(configuration)
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        objectDetectionCheck(anchor, objectNames: buildingStepService.baseModelScanNames)
        objectDetectionCheck(anchor, objectNames: buildingStepService.partNames)
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
        guard let frame = viewARScene.session.currentFrame else { return }
        updateOnEveryFrame(frame)
    }

    private func updateOnEveryFrame(_ frame: ARFrame) {
        arEnvironmentService.updateWithFrameInfo(frame)
    }
}

extension ViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let objectPreviewViewController = storyboard.instantiateViewController(withIdentifier: "ObjectPreviewViewController") as? ObjectPreviewViewController else {
            return
        }
        objectPreviewViewController.buildingStepPart = buildingStepService.parts[indexPath.row]
        present(objectPreviewViewController, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buildingStepService.partNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! PartCell
        cell.setup(with: buildingStepService.parts[indexPath.row])
        return cell
    }
}
