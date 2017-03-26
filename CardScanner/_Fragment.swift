//
//  TextFragment.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

//import Foundation
//import CoreData
//
//private let entityName = "Fragment"
//
//extension _Fragment {
//    
//    var type: FragmentType {
//        get {
//            return FragmentType(rawValue: self.rawType) ?? .unknown
//        }
//        set {
//            self.rawType = newValue.rawValue
//        }
//    }
//    
//    convenience init(type: FragmentType, value: String?, context: NSManagedObjectContext) {
//        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
//            fatalError("Cannot initialize entity \(entityName)")
//        }
//        self.init(entity: entity, insertInto: context)
//        self.identifier = UUID().uuidString
//        self.type = type
//        self.value = value
//    }
//    
//    func allAnnotations() -> [FragmentAnnotation] {
//        var output = [FragmentAnnotation]()
//        
//        if let annotations = self.annotations?.allObjects as? [FragmentAnnotation] {
//            output.append(contentsOf: annotations)
//        }
//        
//        return output
//    }
//    
//    func allVertices() -> [FragmentAnnotationVertex] {
//        
//        var output = [FragmentAnnotationVertex]()
//        
//        let annotations = allAnnotations()
//        for annotation in annotations {
//            output.append(contentsOf: annotation.allVertices())
//        }
//
//        return output
//    }
//}
