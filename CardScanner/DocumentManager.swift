//
//  DocumentManager.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/20.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

class DocumentManager {
    
    private var scanners = [String: ScannerService]()
    
    private var factory: ServiceFactory
    private var coreData: CoreDataStack
    
    init(factory: ServiceFactory, coreData: CoreDataStack) {
        self.factory = factory
        self.coreData = coreData
    }
    
    func createScanner(forDocument identifier: String) -> ScannerService {
        if let scanner = getScanner(forDocument: identifier) {
            return scanner
        }
        let scanner = ScannerService(
            identifier: identifier,
            factory: factory,
            coreData: coreData
        )
        scanners[identifier] = scanner
        return scanner
    }
    
    func getScanner(forDocument identifier: String) -> ScannerService? {
        return scanners[identifier]
    }
    
    func removeScanner(forDocument identifier: String) {
        if let scanner = scanners[identifier] {
            scanner.cancel()
        }
        scanners.removeValue(forKey: identifier)
    }
}
