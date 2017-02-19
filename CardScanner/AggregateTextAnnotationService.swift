//
//  AggregateTextAnnotationService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/19.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

private class AggregateTextAnnotationOperation: AsyncOperation {
    
    typealias ServiceDescriptor = AggregateTextAnnotationService.ServiceDescriptor
    
    private let request: TextAnnotationRequest
    private let services: [ServiceDescriptor]
    private let completion: TextAnnotationCompletion
    private let group: DispatchGroup
    private let queue: DispatchQueue
    
    private var response: TextAnnotationResponse
    
    init(request: TextAnnotationRequest, services: [ServiceDescriptor], completion: @escaping TextAnnotationCompletion) {
        self.request = request
        self.services = services
        self.completion = completion
        self.group = DispatchGroup()
        self.queue = DispatchQueue(label: "AggregateTextAnnotationOperation")
        self.response = TextAnnotationResponse(
            personEntities: [],
            organizationEntities: [],
            addressEntities: [],
            phoneEntities: [],
            urlEntities: [],
            emailEntities: []
        )
    }
    
    fileprivate override func execute(completion: @escaping AsyncOperation.Completion) {
        for service in services {
            runService(service)
        }
        
        group.notify(queue: DispatchQueue.global()) {
            if !self.isCancelled {
                self.completion(self.response, nil)
            }
            completion()
        }
    }
    
    private func runService(_ descriptor: ServiceDescriptor) {
        group.enter()
        descriptor.service.annotate(request: request) { [group] (response, error) in
            if let response = response {
                self.response = descriptor.combine(self.response, response)
            }
            group.leave()
        }
    }
}

struct AggregateTextAnnotationService: TextAnnotationService {
    
    struct ServiceDescriptor {
        typealias Combine = (TextAnnotationResponse, TextAnnotationResponse) -> TextAnnotationResponse
        let service: TextAnnotationService
        let combine: Combine
        static func descriptor(service: TextAnnotationService, combine: @escaping Combine) -> ServiceDescriptor {
            return ServiceDescriptor(
                service: service,
                combine: combine
            )
        }
    }
    
    let services: [ServiceDescriptor]
    let operationQueue: OperationQueue
    
    init(services: [ServiceDescriptor], operationQueue: OperationQueue? = nil) {
        self.services = services
        self.operationQueue = operationQueue ?? OperationQueue()
    }
    
    func annotate(request: TextAnnotationRequest, completion: @escaping TextAnnotationCompletion) -> Cancellable {
        let operation = AggregateTextAnnotationOperation(
            request: request,
            services: services,
            completion: completion
        )
        operationQueue.addOperation(operation)
        return operation
    }
}
