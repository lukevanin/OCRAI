//
//  AggregateTextAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/19.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

private class AggregateTextAnnotationOperation: AsyncOperation {
    
    private let content: Document
    private let services: [TextAnnotationService]
    private let completion: TextAnnotationServiceCompletion
    private let group: DispatchGroup
    private let queue: DispatchQueue
    
    init(content: Document, services: [TextAnnotationService], completion: @escaping TextAnnotationServiceCompletion) {
        self.content = content
        self.services = services
        self.completion = completion
        self.group = DispatchGroup()
        self.queue = DispatchQueue(label: "AggregateTextAnnotationOperation")
    }
    
    fileprivate override func execute(completion: @escaping AsyncOperation.Completion) {
        
        // FIXME: Run services in sequence
        services.forEach(runService)
        
        group.notify(queue: DispatchQueue.global()) {
            if !self.isCancelled {
                self.completion(true, nil)
            }
            completion()
        }
    }
    
    private func runService(_ service: TextAnnotationService) {
        group.enter()
        service.annotate(content: content) { [group] (response, error) in
            group.leave()
        }
    }
}

struct AggregateTextAnnotationService: TextAnnotationService {

    let services: [TextAnnotationService]
    let operationQueue: OperationQueue
    
    init(services: [TextAnnotationService], operationQueue: OperationQueue? = nil) {
        self.services = services
        self.operationQueue = operationQueue ?? OperationQueue()
    }
    
    func annotate(content: Document, completion: @escaping TextAnnotationServiceCompletion) {
        let operation = AggregateTextAnnotationOperation(
            content: content,
            services: services,
            completion: completion
        )
        operationQueue.addOperation(operation)
    }
}
