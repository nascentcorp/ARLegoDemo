//
//  PartsScanViewController.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 20/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import ARKit
import UIKit

class PartsScanViewController: UIViewController {

    private let arEnvironmentService = AREnvironmentService()
    private let cellName = String(describing: PartCell.self)
    private var scannedPartIndexes = [Int]()
    
    @IBOutlet private weak var cnTooDarkToScanningToTop: NSLayoutConstraint!
    @IBOutlet private weak var cvParts: UICollectionView!
    @IBOutlet private weak var lblPartsRemaining: UILabel!
    @IBOutlet private weak var lblScanDescription: UILabel!
    @IBOutlet private weak var lblTooDarkForScanning: UILabel!
    @IBOutlet private weak var viewARScene: ARSCNView!
    
    var buildingStepService: BuildingStepService!

    deinit {
        print("deinit parts scan")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePartsRemainingLabel()
        setupARScene()
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let partsScanViewController = segue.destination as? PartsScanViewController {
//            partsScanViewController.buildingStepService = buildingStepService
//        }
//    }
    
//    @IBAction func btnContinueTapped(_ sender: Any) {
//        performSegue(withIdentifier: "partsScan", sender: nil)
//    }
    
    private func setupARScene() {
        let scene = SCNScene()
        
        viewARScene.scene = scene
        viewARScene.delegate = self
        viewARScene.automaticallyUpdatesLighting = true
    }
    
//    private func displayResultView() {
//        if arEnvironmentService.isDeviceARCapable {
//            viewARScene.session.pause()
//        }
//        guard let scannedObjectModel = self.scannedObjectModel else {
//            assertionFailure("Scanned object model should exist at this point.")
//            return
//        }
//
//        let rotate = SCNAction.rotateBy(x: 0, y: -CGFloat(4 * Float.pi), z: 0, duration: 6)
//        let rotateForever = SCNAction.repeatForever(rotate)
//        scannedObjectModel.runAction(rotateForever)
//
//        UIView.animate(withDuration: 0.7) { [weak self] in
//            guard let `self` = self else { return }
//            self.view3DSceneContainer.alpha = 1.0
//        }
//    }
//
    
    private func updatePartsRemainingLabel() {
        lblPartsRemaining.text = "Parts remaining: \((buildingStepService.partNames.count - scannedPartIndexes.count))"
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

extension PartsScanViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        for i in 0..<buildingStepService.parts.count {
            if scannedPartIndexes.contains(i) {
                break
            }
            let scanNames = buildingStepService.partScanNames(at: i)
            objectDetectionCheck(anchor, objectNames: scanNames, partIndex: i)
        }
    }
    
    private func objectDetectionCheck(_ anchor: ARAnchor, objectNames: [String], partIndex: Int) {
        if
            let objectAnchor = anchor as? ARObjectAnchor,
            let objectName = objectAnchor.referenceObject.name,
            let objectNameIndex = objectNames.firstIndex(where: { $0 == objectName })
        {
            print("|||| Detected object: '\(objectNames[objectNameIndex])' at index: \(partIndex) ||||")
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.scannedPartIndexes.append(partIndex)
                self.updatePartsRemainingLabel()
                
                if let cell = self.cvParts.cellForItem(at: IndexPath(item: partIndex, section: 0)) as? PartCell {
                    UIView.animate(withDuration: 0.3, animations: {
                        cell.alpha = 1.0
                    })
                }

                if self.buildingStepService.partNames.count - self.scannedPartIndexes.count == 0 {
                    // TODO: Display result view
                    //                self.displayResultView()
                }
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

extension PartsScanViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buildingStepService.partNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as! PartCell
        cell.setup(with: buildingStepService.parts[indexPath.row])
        cell.alpha = (scannedPartIndexes.contains(indexPath.row)) ? 1.0 : 0.3
        return cell
    }
}
