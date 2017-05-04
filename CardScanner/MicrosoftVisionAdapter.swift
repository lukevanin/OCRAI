//
//  MicrosoftVisionAdapter.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/23.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import MicrosoftVision

struct MicrosoftVisionAdapter: ImageAnnotationService {
    let service: MicrosoftVisionOCR
    
    func annotate(content: Document, completion: @escaping ImageAnnotationServiceCompletion) {

        DispatchQueue.main.async { [content, service] in
            
            guard let imageData = content.imageData else {
                completion(true, nil)
                return
            }
            
            service.annotate(image: imageData) { (response, error) in
                
                guard let response = response else {
                    completion(false, error)
                    return
                }
                
                DispatchQueue.main.async {
                    self.parseResponse(response: response, content: content)
                    completion(true, nil)
                }
            }
        }
    }
    
    private func parseResponse(response: MicrosoftVisionOCR.Response, content: Document) {
        
        // Compose text
        let paragraphs = response.regions.map() { (region) -> String in
            let sentences = region.lines.map() { (line) -> String in
                let words = line.words.map() { word in
                    return word.text
                }
                return words.joined(separator: " ")
            }
            return sentences.joined(separator: ", ")
        }
        
        let text = paragraphs.joined(separator: ". ")
        
        content.text = text
        
        // Annotate text
//        var range = text.startIndex ..< text.endIndex
//        
//        for region in response.regions {
//            for line in region.lines {
//                for word in line.words {
//                    
//                    guard let wordRange = text.range(of: word.text) else {
//                        fatalError("Expected word \(word) not found in text \(text)")
//                    }
//                    
//                    content.annotate(at: <#T##NSRange#>, vertices: <#T##[CGPoint]#>)
//                    
//                    range = wordRange.upperBound ..< text.endIndex
//                }
//            }
//        }
    }
}
