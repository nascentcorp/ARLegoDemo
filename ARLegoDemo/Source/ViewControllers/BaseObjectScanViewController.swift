//
//  BaseObjectScanViewController.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 19/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import ARKit
import UIKit

class BaseObjectScanViewController: UIViewController {

    private let arEnvironmentService = AREnvironmentService()

    private var scannedObjectModel: SCNNode?
    
    @IBOutlet private weak var cnTooDarkToScanningToTop: NSLayoutConstraint!
    @IBOutlet private weak var lblScanDescription: UILabel!
    @IBOutlet private weak var lblTooDarkForScanning: UILabel!
    @IBOutlet private weak var viewARScene: ARSCNView!
    @IBOutlet private weak var view3DScene: SCNView!
    @IBOutlet private weak var view3DSceneContainer: UIView!
    
    var buildingStepService: BuildingStepService!

    deinit {
        print("deinit base object scan")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupARScene()
        setup3DScene()
        attachObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if arEnvironmentService.isDeviceARCapable {
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
        
        if arEnvironmentService.isDeviceARCapable {
            viewARScene.session.pause()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let partsScanViewController = segue.destination as? PartsScanViewController {
            partsScanViewController.buildingStepService = buildingStepService
        }
    }
    
    @IBAction func btnContinueTapped(_ sender: Any) {
        performSegue(withIdentifier: "partsScan", sender: nil)
    }
    
    private func setup3DScene() {
        let camera = SCNCamera()
        camera.zNear = 0.1
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0.25, z: 0.3)

        let lookAtNode = SCNNode()
        lookAtNode.position = SCNVector3(x: 0, y: 0, z: -0.5)
        
        let mainScene = SCNScene()
        mainScene.rootNode.addChildNode(cameraNode)
        mainScene.rootNode.addChildNode(lookAtNode)

        cameraNode.constraints = [SCNLookAtConstraint(target: lookAtNode)]

        addParts(toScene: mainScene, sceneType: .scene3D)

        view3DScene.scene = mainScene
        view3DScene.backgroundColor = UIColor.black
        view3DScene.autoenablesDefaultLighting = true
    }
    
    private func setupARScene() {
        let scene = SCNScene()
        
        viewARScene.scene = scene
        viewARScene.delegate = self
        viewARScene.automaticallyUpdatesLighting = true
    }

    private func displayResultView() {
        if arEnvironmentService.isDeviceARCapable {
            viewARScene.session.pause()
        }
        guard let scannedObjectModel = self.scannedObjectModel else {
            assertionFailure("Scanned object model should exist at this point.")
            return
        }

        let rotate = SCNAction.rotateBy(x: 0, y: -CGFloat(4 * Float.pi), z: 0, duration: 6)
        let rotateForever = SCNAction.repeatForever(rotate)
        scannedObjectModel.runAction(rotateForever)
        
        UIView.animate(withDuration: 0.7) { [weak self] in
            guard let `self` = self else { return }
            self.view3DSceneContainer.alpha = 1.0
        }
    }
    
    private func addParts(toScene scene: SCNScene, sceneType: SceneType) {
        scannedObjectModel = addPartWorker(buildingStepService.baseModelPart, toScene: scene, sceneType: sceneType)
    }
    
    @discardableResult
    private func addPartWorker(
        _ part: BuildingStepService.BuildingStepPart,
        toScene scene: SCNScene,
        sceneType: SceneType,
        position: SCNVector3 = SCNVector3(),
        shouldAnimate: Bool = false,
        delayFactor: Double = 0.0
        ) -> SCNNode?
    {
        let partScene = SCNScene.create(fromPart: part)
        guard let partNode = partScene.rootNode.childNodes.first else { return nil }
        partNode.setValue(part, forKey: PartNodeKeys.part.rawValue)
        partNode.adjustObjectGeometry(objectType: part.objectType, scale: (sceneType == .scene3D) ? 0.3 : 0.2)
        
        scene.rootNode.addChildNode(partNode)
        
        if !shouldAnimate {
            partNode.position = position
            return partNode
        }
        
        let animationDuration = 1.0
        let rotate = SCNAction.rotateBy(x: 0, y: CGFloat(4 * Float.pi), z: 0, duration: 1.5 * animationDuration)
        let move = SCNAction.move(to: position, duration: animationDuration)
        let initialDelay = SCNAction.wait(duration: delayFactor * 1.5 * animationDuration)
        let group = SCNAction.group([rotate, move])
        let sequence = SCNAction.sequence([initialDelay, group])
        partNode.runAction(sequence)

        return partNode
    }
    
    private func attachObservers() {
        arEnvironmentService.lightingStatusChanged = { [weak self] lightingStatus in
            guard let `self` = self else { return }
            let shouldDisplayWarning = (lightingStatus == .tooDarkForScanning)
            self.cnTooDarkToScanningToTop.constant = (shouldDisplayWarning) ? 0 : -self.lblTooDarkForScanning.bounds.height
            UIView.animate(withDuration: 0.3, animations: {
                self.lblTooDarkForScanning.alpha = (shouldDisplayWarning) ? 1 : 0
                self.view.layoutIfNeeded()
            })
        }
    }
}

extension BaseObjectScanViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        objectDetectionCheck(anchor, objectNames: buildingStepService.baseModelScanNames)
    }
    
    private func objectDetectionCheck(_ anchor: ARAnchor, objectNames: [String]) {
        if
            let objectAnchor = anchor as? ARObjectAnchor,
            let objectName = objectAnchor.referenceObject.name,
            let objectNameIndex = objectNames.firstIndex(where: { $0 == objectName })
        {
            print("|||| Detected object: '\(objectNames[objectNameIndex])' ||||")
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.displayResultView()
            }
        }
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        guard
            let configuration = session.configuration,
            arEnvironmentService.isDeviceARCapable
            else {
                return
        }
        viewARScene.session.run(configuration)
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let frame = viewARScene.session.currentFrame else { return }
        updateOnEveryFrame(frame)
    }
    
    private func updateOnEveryFrame(_ frame: ARFrame) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.arEnvironmentService.updateWithFrameInfo(frame)
        }
    }
}
