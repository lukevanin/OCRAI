//
//  UIViewAnimationCurve+UIViewAnimationOption.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/23.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

extension UIViewAnimationCurve {
    var animationOption: UIViewAnimationOptions {
        switch self {
        case .easeIn:
            return .curveEaseIn
        case .easeOut:
            return .curveEaseOut
        case .easeInOut:
            return .curveEaseInOut
        case .linear:
            return .curveLinear
        }
    }
}
