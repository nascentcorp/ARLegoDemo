//
//  BuildingStepService.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 03/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import Foundation

extension BuildingStepService.BuildingStepPart: Equatable {}

func ==(lhs: BuildingStepService.BuildingStepPart, rhs: BuildingStepService.BuildingStepPart) -> Bool {
    return lhs.id == rhs.id
}

class BuildingStepService {

    struct BuildingStepBaseModel {
        let part: BuildingStepPart
        let scanNames: [String]
    }
    
    struct BuildingStepPart {
        let id: String
        let name: String
        let imageName: String
        let isBaseModel: Bool
        let objectName: String
        let objectType: AcceptedFileType

        init(id: String = UUID().uuidString, name: String, imageName: String, isBaseModel: Bool, objectName: String, objectType: AcceptedFileType) {
            self.id = id
            self.name = name
            self.imageName = imageName
            self.isBaseModel = isBaseModel
            self.objectName = objectName
            self.objectType = objectType
        }
    }
    
    struct BuildingStep {
        let arCatalogName: String
        let baseModel: BuildingStepBaseModel
        let parts: [BuildingStepPart]
    }

    // TODO: This should be loaded from a config file
    private let buildingSteps = [
        BuildingStep(
            arCatalogName: "LegoStep1",
            baseModel: BuildingStepBaseModel(
                part: BuildingStepPart(name: "Statue part", imageName: "statue.png", isBaseModel: false, objectName: "statue", objectType: .obj),
                scanNames: ["baseStepModelTopSide", "baseStepModelBottomSide"]
            ),
            parts: [
                BuildingStepPart(name: "Cube part", imageName: "cube.png", isBaseModel: false, objectName: "cube", objectType: .obj),
                BuildingStepPart(name: "Statue part", imageName: "statue.png", isBaseModel: false, objectName: "statue", objectType: .obj),
                BuildingStepPart(name: "Torus part", imageName: "torus.png", isBaseModel: false, objectName: "torus", objectType: .obj)
            ]
        ),
        BuildingStep(
            arCatalogName: "LegoStep1",
            baseModel: BuildingStepBaseModel(
                part: BuildingStepPart(name: "Batwing Step 2", imageName: "torus.png", isBaseModel: true, objectName: "torus", objectType: .obj),
                scanNames: ["baseStepModelTopSide", "baseStepModelBottomSide"]
            ),
            parts: [
                BuildingStepPart(name: "Cube part", imageName: "cube.png", isBaseModel: false, objectName: "cube", objectType: .obj),
                BuildingStepPart(name: "Statue part", imageName: "statue.png", isBaseModel: false, objectName: "statue", objectType: .obj),
                BuildingStepPart(name: "Torus part", imageName: "torus.png", isBaseModel: false, objectName: "torus", objectType: .obj),
                BuildingStepPart(name: "Cube part", imageName: "cube.png", isBaseModel: false, objectName: "cube", objectType: .obj),
                BuildingStepPart(name: "Statue part", imageName: "statue.png", isBaseModel: false, objectName: "statue", objectType: .obj),
                BuildingStepPart(name: "Torus part", imageName: "torus.png", isBaseModel: false, objectName: "torus", objectType: .obj),
                BuildingStepPart(name: "Cube part", imageName: "cube.png", isBaseModel: false, objectName: "cube", objectType: .obj),
                BuildingStepPart(name: "Statue part", imageName: "statue.png", isBaseModel: false, objectName: "statue", objectType: .obj),
                BuildingStepPart(name: "Torus part", imageName: "torus.png", isBaseModel: false, objectName: "torus", objectType: .obj)
            ]
        )
    ]
    
    private var currentBuildingStepInternal: Int = 0

    var arCatalogName: String {
        return buildingSteps[currentBuildingStepInternal].arCatalogName
    }

    var baseModelPart: BuildingStepPart {
        return buildingSteps[currentBuildingStepInternal].baseModel.part
    }

    var baseModelScanNames: [String] {
        return buildingSteps[currentBuildingStepInternal].baseModel.scanNames
    }

    var numberOfBuildingSteps: Int {
        return buildingSteps.count
    }
    
    var partNames: [String] {
        return buildingSteps[currentBuildingStepInternal].parts.map({ $0.name })
    }

    var parts: [BuildingStepPart] {
        return buildingSteps[currentBuildingStepInternal].parts
    }

    func buildingStep(at index: Int) -> BuildingStep {
        return buildingSteps[index]
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
