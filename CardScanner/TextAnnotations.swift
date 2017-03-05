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
        self.lines = text.components(separatedBy: "\n")
        self.content = lines.joined(separator: "; ")
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
