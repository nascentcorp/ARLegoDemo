//
//  StepSelectionViewController.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 19/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import UIKit

class StepSelectionCell: UITableViewCell {

    @IBOutlet private weak var ivStepBasePart: UIImageView!
    @IBOutlet private weak var lblStepTitle: UILabel!
    @IBOutlet private weak var viewPartsNeededContainer: UIView!
    
    override func prepareForReuse() {
        super.prepareForReuse()

        viewPartsNeededContainer.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    func setup(with step: BuildingStepService.BuildingStep) {
        ivStepBasePart.image = UIImage(named: step.baseModel.imageName)
        lblStepTitle.text = step.baseModel.name

        for i in 0..<step.additionalParts.count {
            let part = step.additionalParts[i]
            
            let partImageView = UIImageView(frame: CGRect(x: i * 52, y: 0, width: 52, height: 52))
            partImageView.image = UIImage(named: part.imageName)
            viewPartsNeededContainer.addSubview(partImageView)
        }
    }
}

class StepSelectionViewController: UIViewController {

    private let arEnvironmentService = AREnvironmentService()
    private let buildingStepService = BuildingStepService()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let stepAssemblyViewController = segue.destination as? StepAssemblyViewController {
            stepAssemblyViewController.buildingStepService = buildingStepService
        }
        else if let baseObjectScanViewController = segue.destination as? BaseObjectScanViewController {
            baseObjectScanViewController.buildingStepService = buildingStepService
        }
    }
}

extension StepSelectionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildingStepService.numberOfBuildingSteps
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepSelectionCell") as! StepSelectionCell
        cell.setup(with: buildingStepService.buildingStep(at: indexPath.row))
        return cell
    }
}

extension StepSelectionViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        buildingStepService.setBuildingStep(at: indexPath.row)
        
        let segueToExecute = "stepAssembly"
//        let segueToExecute = (arEnvironmentService.isDeviceARCapable) ? "baseObjectScan" : "stepAssembly"
        performSegue(withIdentifier: segueToExecute, sender: nil)
    }
}
