//
//  UIColorExtension.swift
//  TapBPM
//
//  Created by Michelle Ellis on 2015-06-26.
//  Copyright (c) 2015 Boltmade. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func randomColor(alpha : CGFloat) -> UIColor {
        return UIColor(hue: randomColorComponent(), saturation: 1, brightness: 1, alpha: alpha)
    }
    
    class func randomColorComponent() -> CGFloat {
        return CGFloat(Double(arc4random_uniform(255))/255.0)
    }
}