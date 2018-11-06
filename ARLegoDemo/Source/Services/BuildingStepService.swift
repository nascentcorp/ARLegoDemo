//
//  BuildingStepService.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 03/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import Foundation

// TODO: Make strutures private if they're not needed in the outside declarations
// TODO: Updated getters to be consistent and use getters only
// TODO: See if we should store current step index or not

extension BuildingStepService.BuildingStepPart: Equatable {}

func ==(lhs: BuildingStepService.BuildingStepPart, rhs: BuildingStepService.BuildingStepPart) -> Bool {
    return lhs.id == rhs.id
}

class BuildingStepService {

    struct BuildingStepPart {
        let id: String
        let name: String
        let imageName: String
        let isBaseModel: Bool
        let objectName: String
        let objectType: AcceptedFileType
        let scanNames: [String]
        
        init(id: String = UUID().uuidString, name: String, imageName: String, isBaseModel: Bool, objectName: String, objectType: AcceptedFileType, scanNames: [String]) {
            self.id = id
            self.name = name
            self.imageName = imageName
            self.isBaseModel = isBaseModel
            self.objectName = objectName
            self.objectType = objectType
            self.scanNames = scanNames
        }
    }
    
    struct BuildingStep {
        let arCatalogName: String
        let baseModel: BuildingStepPart
        let additionalParts: [BuildingStepPart]
    }

    // TODO: This should be loaded from a config file
    private let buildingSteps = [
        BuildingStep(
            arCatalogName: "BatGliderFirstStep",
            baseModel: BuildingStepPart(name: "Roof chasis", imageName: "firstStepRoofChasis-300.png", isBaseModel: true, objectName: "firstStepBase", objectType: .obj,
                scanNames: ["firstStepBaseAngled", "firstStepBaseBottom", "firstStepBaseTop"]),
            additionalParts: [
                BuildingStepPart(name: "Left wing", imageName: "firstStepWingLeft-300.png", isBaseModel: false, objectName: "wingLeft", objectType: .obj,
                                 scanNames: ["firstStepWingTop", "firstStepWingBottom"]),
                BuildingStepPart(name: "Right wing", imageName: "firstStepWingRight-300.png", isBaseModel: false, objectName: "wingRight", objectType: .obj,
                                 scanNames: ["firstStepWingTop", "firstStepWingBottom"])
            ]
        ),
        BuildingStep(
            arCatalogName: "BatGliderFinalStep",
            baseModel: BuildingStepPart(name: "Glider base", imageName: "finalStepGliderBase-300.png", isBaseModel: true, objectName: "finalStepBase", objectType: .obj,
                scanNames: ["finalStepBaseBottom", "finalStepBaseTop"]),
            additionalParts: [
                BuildingStepPart(name: "Glider roof", imageName: "finalStepRoof-300.png", isBaseModel: false, objectName: "completeRoof", objectType: .obj,
                                 scanNames: ["finalStepRoofTop", "finalStepRoofBottom"])
            ]
        )
    ]
    
    private var currentBuildingStepInternal: Int = 0

    var arCatalogName: String {
        return buildingSteps[currentBuildingStepInternal].arCatalogName
    }

    var baseModelPart: BuildingStepPart {
        return buildingSteps[currentBuildingStepInternal].baseModel
    }

    var baseModelScanNames: [String] {
        return buildingSteps[currentBuildingStepInternal].baseModel.scanNames
    }

    var numberOfBuildingSteps: Int {
        return buildingSteps.count
    }
    
    var partNames: [String] {
        return buildingSteps[currentBuildingStepInternal].additionalParts.map({ $0.name })
    }

    var parts: [BuildingStepPart] {
        return buildingSteps[currentBuildingStepInternal].additionalParts
    }

    func buildingStep(at index: Int) -> BuildingStep {
        return buildingSteps[index]
    }

    func partScanNames(at index: Int) -> [String] {
        return buildingSteps[currentBuildingStepInternal].additionalParts[index].scanNames
    }

    func setBuildingStep(at index: Int) {
        currentBuildingStepInternal = (index < 0)
            ? 0
            : (
                (index > buildingSteps.count - 1)
                    ? buildingSteps.count - 1
                    : index
        )
    }
}
