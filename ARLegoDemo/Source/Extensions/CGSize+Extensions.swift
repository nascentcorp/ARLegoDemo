//
//  CGSize+Extensions.swift
//  ARLegoDemo
//
//  Created by Miran Brajsa on 14/10/2018.
//  Copyright © 2018 Nascentcorp.io. All rights reserved.
//

import UIKit

extension CGSize {

    static func *(lhs: CGSize, rhs: Double) -> CGSize {
        return CGSize(width: Double(lhs.width) * rhs, height: Double(lhs.height) * rhs)
    }
}
