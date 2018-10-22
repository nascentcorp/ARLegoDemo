//
//  StepAssemblyViewController.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 28/09/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import ARKit
import UIKit

class PartCell: UICollectionViewCell {

    var part: BuildingStepService.BuildingStepPart?

    @IBOutlet private weak var ivPartImage: UIImageView!
    @IBOutlet private weak var lblPartName: UILabel!
    
    func setup(with part: BuildingStepService.BuildingStepPart) {
        self.part = part

        lblPartName.text = part.name
        ivPartImage.image = UIImage(named: part.imageName)
    }
}

enum SceneType {
    case sceneAR
    case scene3D
}

enum PartNodeKeys: String {
    case actionsNode
    case part
}

class StepAssemblyViewController: UIViewController {

    private let arEnvironmentService = AREnvironmentService()
    private let cellName = String(describing: PartCell.self)
    
    private var scene3DSetup = false
    private var selectedNode: SCNNode?

    @IBOutlet private weak var cvParts: UICollectionView!
    @IBOutlet private weak var ivBaseObjectImage: UIImageView!
    @IBOutlet private weak var lblBaseObjectName: UILabel!
    @IBOutlet private weak var sgmSceneSwitch: UISegmentedControl!
    @IBOutlet private weak var view3DScene: SCNView!
    @IBOutlet private weak var viewActions: UIView!
    @IBOutlet private weak var viewARScene: ARSCNView!

    var buildingStepService: BuildingStepService!

    var activeSceneType: SceneType {
        if !arEnvironmentService.isDeviceARCapable {
            return .scene3D
        }
        return (sgmSceneSwitch.selectedSegmentIndex == 0) ? .sceneAR : .scene3D
    }

    var activeSceneView: SCNView {
        return (activeSceneType == .sceneAR) ? viewARScene : view3DScene
    }
    
    deinit {
        print("deinit step assembly")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We want 3D scene to be setup when first selected on AR capable devices.
        if arEnvironmentService.isDeviceARCapable {
            setupARScene()
        }
        else {
            setup3DScene()
        }
        setupAppearance()
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
    
    @IBAction func btnBaseObjectPreviewTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let objectPreviewViewController = storyboard.instantiateViewController(withIdentifier: "ObjectPreviewViewController") as? ObjectPreviewViewController else {
            return
        }
        objectPreviewViewController.buildingStepPart = buildingStepService.baseModelPart
        present(objectPreviewViewController, animated: true)
    }

    @IBAction func btnObjectInfoTapped(_ sender: Any) {
        guard
            let selectedNode = selectedNode,
            let part = getNodePart(selectedNode)
            else {
                return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let objectPreviewViewController = storyboard.instantiateViewController(withIdentifier: "ObjectPreviewViewController") as? ObjectPreviewViewController else {
            return
        }
        objectPreviewViewController.buildingStepPart = part
        present(objectPreviewViewController, animated: true)

    }
    
    @IBAction func btnObjectConnectTapped(_ sender: Any) {
    }
    
    @IBAction func btnSceneSwitchTapped(_ sender: UISegmentedControl) {
        let sceneARSelected = (sender.selectedSegmentIndex == 0)
        if !sceneARSelected && !scene3DSetup {
            scene3DSetup = true
            setup3DScene()
        }
        view3DScene.isHidden = sceneARSelected
        viewARScene.isHidden = !sceneARSelected
    }
    
    private func setupAppearance() {
        lblBaseObjectName.text = buildingStepService.baseModelPart.name
        ivBaseObjectImage.image = UIImage(named: buildingStepService.baseModelPart.imageName)
        
        if !arEnvironmentService.isDeviceARCapable {
            sgmSceneSwitch.isHidden = true
            view3DScene.isHidden = false
            viewARScene.isHidden = true
        }
    }
    
    private func setupARScene() {
        let scene = SCNScene()

        addParts(toScene: scene, sceneType: .sceneAR)

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

        addParts(toScene: mainScene, sceneType: .scene3D)

        view3DScene.scene = mainScene
        view3DScene.backgroundColor = UIColor.black
        view3DScene.allowsCameraControl = true
        view3DScene.autoenablesDefaultLighting = true
    }
    
    private func addParts(toScene scene: SCNScene, sceneType: SceneType) {
        addPartWorker(buildingStepService.baseModelPart, toScene: scene, sceneType: sceneType)
        for i in 0..<buildingStepService.parts.count {
            let part = buildingStepService.parts[i]
            let radius = (sceneType == .scene3D) ? 0.7 : 0.5
            let angle = Double(i) / (Double(buildingStepService.parts.count) / 2.0) * Double.pi - Double.pi / 2.0
            let position = SCNVector3(
                radius * cos(angle),
                0.0,
                radius * sin(angle)
            )
            let delayFactor = Double(i) / Double(buildingStepService.parts.count)
            addPartWorker(part, toScene: scene, sceneType: sceneType, position: position, shouldAnimate: true, delayFactor: delayFactor)
        }
    }
    
    private func addPartWorker(
        _ part: BuildingStepService.BuildingStepPart,
        toScene scene: SCNScene,
        sceneType: SceneType,
        position: SCNVector3 = SCNVector3(),
        shouldAnimate: Bool = false,
        delayFactor: Double = 0.0
        )
    {
        let partScene = SCNScene.create(fromPart: part)
        guard let partNode = partScene.rootNode.childNodes.first else { return }
        partNode.setValue(part, forKey: PartNodeKeys.part.rawValue)
        partNode.adjustObjectGeometry(objectType: part.objectType, scale: (sceneType == .scene3D) ? 0.3 : 0.2)

        scene.rootNode.addChildNode(partNode)

        if !shouldAnimate {
            partNode.position = position
            return
        }
        
        let animationDuration = 1.0
        let rotate = SCNAction.rotateBy(x: 0, y: CGFloat(4 * Float.pi), z: 0, duration: 1.5 * animationDuration)
        let move = SCNAction.move(to: position, duration: animationDuration)
        let initialDelay = SCNAction.wait(duration: delayFactor * 1.5 * animationDuration)
        let group = SCNAction.group([rotate, move])
        let sequence = SCNAction.sequence([initialDelay, group])
        partNode.runAction(sequence)
    }
}

extension StepAssemblyViewController {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let results = activeSceneView.hitTest(touch.location(in: activeSceneView), options: nil)
        
        guard let scene = activeSceneView.scene else { return }
        guard let node = results.first?.node else {
            highlightWorker(SCNNode(), scene: scene, toggleHighlight: true)
            selectedNode = nil
            return
        }
        
        if
            let part = getNodePart(node),
            !part.isBaseModel
        {
            highlight(node, scene: scene)
            selectedNode = node
        }
        else {
            highlightWorker(SCNNode(), scene: scene, toggleHighlight: true)
            selectedNode = nil
        }

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
    }

    private func highlight(_ node: SCNNode, scene: SCNScene) {
        highlightWorker(node, scene: scene)
    }

    private func highlightWorker(_ node: SCNNode, scene: SCNScene, toggleHighlight: Bool? = nil) {
        let animationDuration = 0.3
        UIView.animate(withDuration: animationDuration) {
            self.viewActions.alpha = (toggleHighlight != nil) ? 0 : 1
        }
        scene.rootNode.childNodes.forEach({ otherPartNode in
            guard
                let part = getNodePart(otherPartNode),
                !part.isBaseModel
                else {
                    return
            }
            let lowOpacity: CGFloat = 0.3
            let highOpacity: CGFloat = 1.0
            let targetOpacity: CGFloat = (toggleHighlight != nil)
                ? ((toggleHighlight ?? true)
                    ? highOpacity
                    : lowOpacity
                    )
                : ((otherPartNode == node)
                    ? highOpacity
                    : lowOpacity
            )
            let opacityAction = SCNAction.fadeOpacity(to: targetOpacity, duration: animationDuration)
            otherPartNode.runAction(opacityAction)
        })
    }

    private func getNodePart(_ node: SCNNode) -> BuildingStepService.BuildingStepPart? {
        return node.value(forKey: PartNodeKeys.part.rawValue) as? BuildingStepService.BuildingStepPart
    }
}

extension StepAssemblyViewController: ARSCNViewDelegate {

    func sessionInterruptionEnded(_ session: ARSession) {
        guard
            let configuration = session.configuration,
            arEnvironmentService.isDeviceARCapable
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

extension StepAssemblyViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let partCell = collectionView.cellForItem(at: indexPath) as! PartCell
        guard
            let cellPart = partCell.part,
            let scene = activeSceneView.scene
            else {
                return
        }
        for i in 0..<scene.rootNode.childNodes.count {
            let node = scene.rootNode.childNodes[i]
            if
                let nodePart = node.value(forKey: PartNodeKeys.part.rawValue) as? BuildingStepService.BuildingStepPart,
                nodePart == cellPart
            {
                highlight(node, scene: scene)
                selectedNode = node
                break
            }
        }
    }
}

extension StepAssemblyViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buildingStepService.partNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! PartCell
        cell.setup(with: buildingStepService.parts[indexPath.row])
        return cell
    }
}
