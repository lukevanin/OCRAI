//
//  AnnotationsRenderer.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/28.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import CoreGraphics

protocol AnnotationsRenderer {
    func render(size: CGSize) -> UIImage?
}

