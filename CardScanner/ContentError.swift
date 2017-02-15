//
//  ContentError.swift
//  AutoTranslate
//
//  Created by Luke Van In on 2017/02/06.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case undefined
    case connection(Error)
    case http(Int)
    case content(Error)
    case parse
}
