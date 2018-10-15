//
//  BuildingStepService.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 03/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import Foundation

class BuildingStepService {

    private struct BuildingStepBaseModel {
        let part: BuildingStepPart
        let scanNames: [String]
    }
    
    struct BuildingStepPart {
        let name: String
        let imageName: String
        let objectName: String
        let objectType: AcceptedFileType
    }
    
    private struct BuildingStep {
        let arCatalogName: String
        let baseModel: BuildingStepBaseModel
        let parts: [BuildingStepPart]
    }

    // TODO: This should be loaded from a config file
    private let buildingSteps = [
        BuildingStep(
            arCatalogName: "LegoStep1",
            baseModel: BuildingStepBaseModel(
                part: BuildingStepPart(name: "This step's base object", imageName: "torus.png", objectName: "torus", objectType: .obj),
                scanNames: ["baseStepModelTopSide", "baseStepModelBottomSide"]
            ),
            parts: [
                BuildingStepPart(name: "Cube part", imageName: "cube.png", objectName: "cube", objectType: .obj),
                BuildingStepPart(name: "Statue part", imageName: "statue.png", objectName: "statue", objectType: .obj)
            ]
        )
    ]
    
    private var currentBuildingStepInternal: Int = 0

    var currentBuildingStep: Int {
        return currentBuildingStepInternal
    }

    var arCatalogName: String {
        return buildingSteps[currentBuildingStepInternal].arCatalogName
    }

    var baseModelPart: BuildingStepPart {
        return buildingSteps[currentBuildingStepInternal].baseModel.part
    }

    var baseModelScanNames: [String] {
        return buildingSteps[currentBuildingStepInternal].baseModel.scanNames
    }

    var partNames: [String] {
        return buildingSteps[currentBuildingStepInternal].parts.map({ $0.name })
    }

    var parts: [BuildingStepPart] {
        return buildingSteps[currentBuildingStepInternal].parts
    }

    func nextBuildingStep() {
        if currentBuildingStepInternal < buildingSteps.count - 1 {
            currentBuildingStepInternal += 1
        }
    }

    func previousBuildingStep() {
        if currentBuildingStepInternal > 0 {
            currentBuildingStepInternal -= 1
        }
    }
}
