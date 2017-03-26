//
//  FragmentType+Color.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/01.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

extension FieldType {
    var color: UIColor {
        return UIColor(white: 0.33, alpha: 1.0)
    }
    
    var accentColor: UIColor {
        switch self {
        case .address:
            return Material.Color.orange
            
        case .person:
            return Material.Color.pink
            
        case .organization:
            return Material.Color.green
            
        case .email:
            return Material.Color.lightBlue
            
        case .url:
            return Material.Color.teal
            
        case .phoneNumber:
            return Material.Color.cyan
            
        case .note:
            return Material.Color.lime
            
        default:
            return Material.Color.grey
        }
    }
}
