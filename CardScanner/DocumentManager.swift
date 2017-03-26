//
//  DocumentManager.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/20.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

class DocumentManager {
    
    private var scanners = [Document: ScannerService]()
    
    private var factory: ServiceFactory
    private var coreData: CoreDataStack
    
    init(factory: ServiceFactory, coreData: CoreDataStack) {
        self.factory = factory
        self.coreData = coreData
    }
    
    func createScanner(forDocument document: Document) -> ScannerService {
        assert(Thread.isMainThread)
        if let scanner = getScanner(forDocument: document) {
            return scanner
        }
        let scanner = ScannerService(
            document: document,
            factory: factory,
            coreData: coreData
        )
        scanners[document] = scanner
        return scanner
    }
    
    func getScanner(forDocument document: Document) -> ScannerService? {
        assert(Thread.isMainThread)
        return scanners[document]
    }
    
    func removeScanner(forDocument document: Document) {
        assert(Thread.isMainThread)
        if let scanner = scanners[document] {
            scanner.cancel()
        }
        scanners.removeValue(forKey: document)
    }
}
