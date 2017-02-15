//
//  AsyncOperation.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/09.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

class AsyncOperation: Operation, Cancellable {
    
    typealias Completion = () -> Void
    
    override var isConcurrent: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        return self.internalExecuting
    }
    
    override var isFinished: Bool {
        return self.internalFinished
    }
    
    private var internalExecuting = false {
        willSet {
            self.willChangeValue(forKey: "isExecuting")
        }
        didSet {
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    
    private var internalFinished = false {
        willSet {
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isFinished")
        }
    }

    override func start() {
        super.start()
        
        guard !isCancelled else {
            return
        }
        
        beginExecuting()
        
        execute() {
            self.finishExecuting()
        }
    }
    
    open func execute(completion: @escaping Completion) {
        completion()
    }
    
    private func beginExecuting() {
        internalExecuting = true
    }
    
    private func finishExecuting() {
        guard !isCancelled else {
            // Operation cancelled
            return
        }
        internalExecuting = false
        internalFinished = true
    }
}
