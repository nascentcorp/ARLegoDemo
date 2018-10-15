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
        let names: [String]
        let imageName: String
    }
    
    struct BuildingStepPart {
        let name: String
        let imageName: String
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
            baseModel: BuildingStepBaseModel(names: ["baseStepModelTopSide", "baseStepModelBottomSide"], imageName: ""),
            parts: [
                BuildingStepPart(name: "cube", imageName: "cube.png", objectType: .obj),
                BuildingStepPart(name: "statue", imageName: "", objectType: .obj)
            ]
        )
    ]
    
    private var currentBuildingStepInternal: Int = 0

    var currentBuildingStep: Int {
        return currentBuildingStepInternal
    }

    var catalogName: String {
        return buildingSteps[currentBuildingStepInternal].arCatalogName
    }

    var baseModelScanNames: [String] {
        return buildingSteps[currentBuildingStepInternal].baseModel.names
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
