//
//  ImageAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

typealias ImageAnnotationServiceCompletion = (Bool, Error?) -> Void

protocol ImageAnnotationService {
    func annotate(content: Document, completion: @escaping ImageAnnotationServiceCompletion)
}

