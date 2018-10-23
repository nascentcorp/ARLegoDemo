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
            arCatalogName: "LegoStep1",
            baseModel: BuildingStepPart(name: "Statue part", imageName: "statue.png", isBaseModel: true, objectName: "statue", objectType: .obj,
                scanNames: ["baseStepModelTopSide", "baseStepModelBottomSide"]),
            additionalParts: [
                BuildingStepPart(name: "Cube part", imageName: "cube.png", isBaseModel: false, objectName: "cube", objectType: .obj,
                                 scanNames: ["baseStepModelTopSide", "baseStepModelBottomSide"]),
                BuildingStepPart(name: "Statue part", imageName: "statue.png", isBaseModel: false, objectName: "statue", objectType: .obj,
                                 scanNames: ["baseStepModelTopSide", "baseStepModelBottomSide"]),
                BuildingStepPart(name: "Torus part", imageName: "torus.png", isBaseModel: false, objectName: "torus", objectType: .obj,
                                 scanNames: ["baseStepModelTopSide", "baseStepModelBottomSide"])
            ]
        ),
        BuildingStep(
            arCatalogName: "LegoStep1",
            baseModel: BuildingStepPart(name: "Batwing Step 2", imageName: "torus.png", isBaseModel: true, objectName: "torus", objectType: .obj,
                scanNames: ["baseStepModelTopSide", "baseStepModelBottomSide"]),
            additionalParts: [
                BuildingStepPart(name: "Cube part", imageName: "cube.png", isBaseModel: false, objectName: "cube", objectType: .obj, scanNames: []),
                BuildingStepPart(name: "Statue part", imageName: "statue.png", isBaseModel: false, objectName: "statue", objectType: .obj, scanNames: []),
                BuildingStepPart(name: "Torus part", imageName: "torus.png", isBaseModel: false, objectName: "torus", objectType: .obj, scanNames: []),
                BuildingStepPart(name: "Cube part", imageName: "cube.png", isBaseModel: false, objectName: "cube", objectType: .obj, scanNames: []),
                BuildingStepPart(name: "Statue part", imageName: "statue.png", isBaseModel: false, objectName: "statue", objectType: .obj, scanNames: []),
                BuildingStepPart(name: "Torus part", imageName: "torus.png", isBaseModel: false, objectName: "torus", objectType: .obj, scanNames: []),
                BuildingStepPart(name: "Cube part", imageName: "cube.png", isBaseModel: false, objectName: "cube", objectType: .obj, scanNames: []),
                BuildingStepPart(name: "Statue part", imageName: "statue.png", isBaseModel: false, objectName: "statue", objectType: .obj, scanNames: []),
                BuildingStepPart(name: "Torus part", imageName: "torus.png", isBaseModel: false, objectName: "torus", objectType: .obj, scanNames: [])
            ]
        ),
        BuildingStep(
            arCatalogName: "BatmanFinalStep",
            baseModel: BuildingStepPart(name: "Batman glider", imageName: "baseObject-300.png", isBaseModel: true, objectName: "statue", objectType: .obj,
                                        scanNames: ["baseObjectBottom", "baseObjectTop"]),
            additionalParts: [
                BuildingStepPart(name: "Wing", imageName: "wing-300.png", isBaseModel: false, objectName: "cube", objectType: .obj,
                                 scanNames: ["wingBottom", "wingTop"]),
                BuildingStepPart(name: "Engine", imageName: "engine-300.png", isBaseModel: false, objectName: "statue", objectType: .obj,
                                 scanNames: ["engineTop", "engineBottom", "engineSide"]),
                BuildingStepPart(name: "Tail", imageName: "tail-300.png", isBaseModel: false, objectName: "torus", objectType: .obj,
                                 scanNames: ["tailAngled", "tailLeft", "tailRight"])
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
