//
//  ScannerService.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import CoreLocation

protocol ScannerObserver: NSObjectProtocol {
    func scanner(service: ScannerService, didChangeState state: ScannerService.State)
}

class ScannerService {
    
    enum State {
        case idle
        case active
        case completed
    }
    
    private var observers = [ScannerObserver]()
    
    var state = State.idle {
        didSet {
            if state != oldValue {
                notifyObservers(withState: state)
            }
        }
    }
    
    let identifier: String
    
    private let factory: ServiceFactory
    private let coreData: CoreDataStack
    private let operationQueue: OperationQueue
    
    init(identifier: String, factory: ServiceFactory, coreData: CoreDataStack, queue: OperationQueue? = nil) {
        self.identifier = identifier
        self.factory = factory
        self.coreData = coreData
        self.operationQueue = queue ?? OperationQueue()
    }
    
    // MARK: Observer
    
    func addObserver(_ observer: ScannerObserver) {
        assert(Thread.isMainThread)
        removeObserver(observer)
        observers.append(observer)
    }
    
    func removeObserver(_ observer: ScannerObserver) {
        assert(Thread.isMainThread)
        observers = observers.filter { $0 !== observer }
    }
    
    private func notifyObservers(withState state: State) {
        assert(Thread.isMainThread)
        let queue = DispatchQueue.global(qos: .default)
        observers.forEach { observer in
            queue.async {
                observer.scanner(service: self, didChangeState: state)
            }
        }
    }
    
    // MARK: State
    
    func cancel() {
        operationQueue.cancelAllOperations()
        state = .idle
    }
    
    func scan() {
        
        assert(Thread.isMainThread)

        guard state == .idle else {
            // Scanning already in progress
            return
        }

        state = .active

        let operation = ScanOperation(
            document: identifier,
            service: self,
            coreData: coreData
        )

        operation.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.state = .completed
                self?.state = .idle
            }
        }

        operationQueue.addOperation(operation)
    }
    
    func annotateImage(image: Data, completion: @escaping (ImageAnnotationResponse?) -> Void) {
        guard let service = factory.imageAnnotationService() else {
            completion(nil)
            return
        }
        let request = ImageAnnotationRequest(
            image: image,
            feature: [.text]
        )
        service.annotate(request: request) { response, error in
            completion(response)
        }
    }
    
    func annotateText(text: AnnotatedText, completion: @escaping (TextAnnotationResponse?) -> Void) {
        guard let service = factory.textAnnotationService() else {
            completion(nil)
            return
        }
        let request = TextAnnotationRequest(
            text: text
        )
        service.annotate(request: request) { (response, error) in
            completion(response)
        }
    }
}
