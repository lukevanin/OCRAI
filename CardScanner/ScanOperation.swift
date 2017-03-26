//
//  ScanOperation.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import CoreLocation
import Contacts
import CoreData

class ScanOperation: AsyncOperation {
    
    let document: Document
    
    private let factory: ServiceFactory
    private let coreData: CoreDataStack
    
    init(document: Document, factory: ServiceFactory, coreData: CoreDataStack) {
        self.document = document
        self.factory = factory
        self.coreData = coreData
    }
    
    override func cancel() {
        // FIXME: Cancel pending operations
        super.cancel()
    }
    
    override func execute(completion: @escaping () -> Void) {
        annotate() { [document, coreData] in
            coreData.performChangesOnMainQueue { context in
                document.didCompleteScan = true
                coreData.saveNow()
                completion()
            }
        }
    }
    
    private func annotate(completion: @escaping () -> Void) {
        coreData.performChangesOnMainQueue { [document, coreData] context in

            document.allTags.forEach(context.delete)
            document.allAnnotations.forEach(context.delete)
            document.allFields.forEach(context.delete)
            document.didCompleteScan = false
            
            coreData.saveNow()
            
            self.annotateImage() {
                self.annotateText() {
                    self.createFields() {
                        completion()
                    }
                }
            }
        }
    }
    
    private func annotateImage(completion: @escaping () -> Void) {
        let service = factory.imageAnnotationService()
        service.annotate(content: document) { (success, error) in
            completion()
        }
    }
    
    func annotateText(completion: @escaping () -> Void) {
        let service = factory.textAnnotationService()
        service.annotate(content: document) { (response, error) in
            completion()
        }
    }
    
    func createFields(completion: @escaping () -> Void) {
        coreData.performChangesOnMainQueue() { [document, coreData] context in
            
            // Create fields from tags
            for tag in document.allTags {
                
                guard let text = tag.text else {
                    return
                }
                
                let field = Field(
                    type: tag.type,
                    value: text,
                    context: context
                )
                
                document.addToFields(field)
            }
            
            // Save
            coreData.saveNow()
            completion()
        }
    }
}
