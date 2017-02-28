//
//  TextAnnotations.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/27.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct AnnotatedText {
    
    private struct TextAnnotation {
        let range: Range<String.Index>
        let annotation: Annotation
    }
    
    let content: String
    let lines: [String]
    
    private var annotations: [TextAnnotation]
    
    init(text: String) {
        self.content = text
        self.lines = text.components(separatedBy: "\n")
        self.annotations = []
    }
    
    mutating func addAnnotation(_ annotation: Annotation, forRange range: Range<String.Index>) {
        let annotation = TextAnnotation(range: range, annotation: annotation)
        annotations.append(annotation)
    }
    
    func getPolygons(forRange range: Range<String.Index>) -> [Polygon] {
        return getAnnotations(forRange: range).map { $0.bounds }
    }
    
    func getAnnotations(forRange range: Range<String.Index>) -> [Annotation] {
        return getTextAnnotations(forRange: range).map { $0.annotation }
    }
    
    private func getTextAnnotations(forRange range: Range<String.Index>) -> [TextAnnotation] {
        return annotations.filter { range.overlaps($0.range) }
    }
    
    func convertRange(_ range: NSRange) -> Range<String.Index> {
        let start = content.index(content.startIndex, offsetBy: range.location)
        let end = content.index(start, offsetBy: range.length)
        return start ..< end
    }
}

//struct TextAnnotations {
//    let annotations: [Annotation]
//    
//    var lines: [String] {
//        return annotations.map({ $0.content + "\n" })
//    }
//    
//    func annotationsForRange(_ range: NSRange) -> [Annotation] {
//        let firstLine = lineIndexForCharacterIndex(range.location)
//        let lastLine = lineIndexForCharacterIndex(range.location + range.length)
//        return Array(annotations.prefix(lastLine).suffix(firstLine))
//    }
//    
//    func lineIndexForCharacterIndex(_ index: Int) -> Int {
//        // E.g.
//        //  Strings = [Peter, John, Tim]
//        //  Lengths = [5, 4, 3]
//        //  Character c = 11 (m in Tim)
//        //  Expected line = 2
//        //
//        // Algorithm:
//        //  c = 11, line = 0
//        //  c = c - 5 = 11 - 5 = 6, line = line + 1 = 1
//        //  c = c - 4 = 6 - 4 = 2, line = line + 1 = 2
//        //  return line = 2
//        
//        let lineLengths = lines.map({ $0.characters.count })
//        var line = 0
//        var c = index
//        
//        while (line < lineLengths.count && c > lineLengths[line]) {
//            c = c - lineLengths[line]
//            line += 1
//        }
//        
//        return line
//    }
//}
