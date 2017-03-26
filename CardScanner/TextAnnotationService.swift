//
//  TextAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

typealias TextAnnotationServiceCompletion = (Bool, Error?) -> Void

protocol TextAnnotationService {
    func annotate(content: Document, completion: @escaping TextAnnotationServiceCompletion)
}
