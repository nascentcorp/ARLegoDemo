//
//  BuildingStepService.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 03/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import Foundation

class BuildingStepService {

    private struct BuildingStep {
        let arCatalogName: String
        let baseModelScanNames: [String]
        let partsNames: [String]
    }

    // TODO: This should be loaded from a config file
    private let buildingSteps = [
        BuildingStep(
            arCatalogName: "LegoStep1",
            baseModelScanNames: ["baseStepModelTopSide", "baseStepModelBottomSide"],
            partsNames: ["part1BottomSide",  "part1TopSide"]
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
        return buildingSteps[currentBuildingStepInternal].baseModelScanNames
    }

    var partsNames: [String] {
        return buildingSteps[currentBuildingStepInternal].partsNames
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
