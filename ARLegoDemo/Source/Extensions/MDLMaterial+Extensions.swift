//
//  MDLMaterial+Extensions.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 04/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import SceneKit
import SceneKit.ModelIO

extension MDLMaterial {
    
    func setTextureProperties(textures: [MDLMaterialSemantic:String]) -> Void {
        for (key,value) in textures {
            guard let url = Bundle.main.url(forResource: value, withExtension: "") else {
                fatalError("Failed to find URL for resource \(value).")
            }
            let property = MDLMaterialProperty(name:value, semantic: key, url: url)
            self.setProperty(property)
        }
    }
}
