//
//  TextAnnotations.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/27.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

extension String {
    func convertRange(_ range: NSRange) -> Range<String.Index> {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(start, offsetBy: range.length)
        return start ..< end
    }
}

private struct TextAnnotation<ContentType> {
    let range: Range<String.Index>
    let content: ContentType
}

struct AnnotatedText {
    
    typealias EnumerateTag = (_ type: FragmentType, _ text: String, _ normalizedText: String?, _ range: Range<String.Index>) -> Void
    
    struct TextTag {
        let type: FragmentType
        let normalizedContent: String?
    }
    
    private struct TextLine {
        let range: Range<String.Index>
        let content: String
    }
    
    var lines: [String] {
        return textLines.map { $0.content }
    }
    
    let content: String
    private let textLines: [TextLine]
    
    private var polygonAnnotations: [TextAnnotation<Annotation>]
    private var tagAnnotations: [TextAnnotation<TextTag>]
    
    init(text: String) {
        self.init(text: text, delimiter: "\n")
    }
    
    init(text: String, delimiter: String) {
        let lines = text.components(separatedBy: delimiter)
        self.init(lines: lines)
    }
    
    init(lines: [String]) {

        let separator = ", "
        let content = lines.joined(separator: separator)

        var textLines = [TextLine]()
        var start = 0
        var end = 0
        
        for line in lines {
            let length = line.characters.count
            end = start + length
            let startIndex = content.index(content.startIndex, offsetBy: start)
            let endIndex = content.index(content.startIndex, offsetBy: end)
            let range = startIndex ..< endIndex
            start = end + separator.characters.count
            
            let textLine = TextLine(
                range: range,
                content: line
            )
            textLines.append(textLine)
        }
        
        self.textLines = textLines
        self.content = content
        self.polygonAnnotations = []
        self.tagAnnotations = []
    }
    
    // MARK: Text
    
    func text(in range: Range<String.Index>) -> String {
        return content.substring(with: range)
    }

    // MARK: Polygon annotations
    
    mutating func add(shape annotation: Annotation, in range: Range<String.Index>) {
        let annotation = TextAnnotation(range: range, content: annotation)
        polygonAnnotations.append(annotation)
    }
    
    func shapes(in range: Range<String.Index>) -> [Annotation] {
        return filter(annotations: polygonAnnotations, in: range).map { $0.content }
    }
    
    func shapePolygons(in range: Range<String.Index>) -> [Polygon] {
        return shapes(in: range).map { $0.bounds }
    }
    
    // MARK: Tag annotations
    
    mutating func add(type: FragmentType, atLine index: Int, text: String? = nil) {
        let line = lines[index]
        let range = makeRange(
            location: 0,
            length: line.characters.count
        )
        add(type: type, text: text, in: range)
    }
    
    mutating func add(type: FragmentType, text: String? = nil, in range: Range<String.Index>) {
        let tag = TextTag(
            type: type,
            normalizedContent: text
        )
        
        add(tag: tag, in: range)
    }
    
    private mutating func add(tag: TextTag, in range: Range<String.Index>) {
        let annotation = TextAnnotation(range: range, content: tag)
        tagAnnotations.append(annotation)
    }
    
    func tags(in range: Range<String.Index>) -> [TextTag] {
        return filter(annotations: tagAnnotations, in: range).map { $0.content }
    }
    
    func tagTypes(in range: Range<String.Index>) -> [FragmentType] {
        return tags(in: range).map { $0.type }
    }
    
    func enumerateTags(enumerate: EnumerateTag) {
        tagAnnotations.forEach() {
            let text = self.text(in: $0.range)
            enumerate($0.content.type, text, $0.content.normalizedContent, $0.range)
        }
    }
    
    // MARK: Utilities
    
    private func filter<ContentType>(annotations: [TextAnnotation<ContentType>], in range: Range<String.Index>) -> [TextAnnotation<ContentType>] {
        return annotations.filter { range.overlaps($0.range) }
    }
    
    func makeRange(location: Int, length: Int) -> Range<String.Index> {
        return convertRange(NSRange(location: location, length: length))
    }
    
    func convertRange(_ input: NSRange) -> Range<String.Index> {
        return content.convertRange(input)
    }
}
