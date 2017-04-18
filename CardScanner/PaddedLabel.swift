//
//  PaddedLabel.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/11.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.insetBy(dx: 0, dy: -4))
    }
}
