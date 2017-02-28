//
//  GoogleTextAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/13.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

//struct GoogleTextAnnotationService: TextAnnotationService {
//    
//    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) -> Cancellable {
//        fatalError("not implemented")
//        let components = text.components(separatedBy: .newlines)
//        let digest = components.joined(separator: ", ")
//        
//        let request = AnalyzeEntitiesRequest(
//            encodingType: .utf8,
//            document: Document(
//                type: .plaintext,
//                language: "EN",
//                content: digest
//            )
//        )
//        let api = GoogleNaturalLanguageAPI(key: googleKey)
//        api.analyzeEntities(request: request) { (response, error) in
//            
//        }
//    }
//}
