//
//  ColorConverter.swift
//  PetoiControllerSwift
//
//  Created by Orlando Chen on 2021/3/31.
//

import Foundation
import UIKit


class ColorConverter {
    
    static func convert(color: UIColor) ->CGColor {
        return color.cgColor
    }
    
    
    static func convert(color: CGColor) ->UIColor {
        return UIColor(cgColor: color)
    }
}
