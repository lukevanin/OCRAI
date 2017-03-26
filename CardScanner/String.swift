//
//  String.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/25.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

extension String {
    func convertRange(_ range: NSRange) -> Range<String.Index> {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        return start ..< end
    }
    
    func convertRange(_ range: Range<String.Index>) -> NSRange {
        let location = distance(from: startIndex, to: range.lowerBound)
        let length = distance(from: range.lowerBound, to: range.upperBound)
        return NSRange(location: location, length: length)
    }
}
