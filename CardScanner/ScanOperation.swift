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
    
    typealias ProcessEntity = (Entity, NSManagedObjectContext) throws -> Void
    
    private let identifier: String
    private let service: ScannerService
    private let coreData: CoreDataStack
    private let progress: ScannerService.ProgressHandler
    private let queue: DispatchQueue
    private let group: DispatchGroup
    
    private var state: ScannerService.State = .pending {
        didSet {
            self.progress(state)
        }
    }
    
    init(document identifier: String, service: ScannerService, coreData: CoreDataStack, progress: @escaping ScannerService.ProgressHandler) {
        self.identifier = identifier
        self.service = service
        self.coreData = coreData
        self.progress = progress
        self.queue = DispatchQueue(label: "ScannerServiceOperation")
        self.group = DispatchGroup()
    }
    
    override func cancel() {
        // FIXME: Cancel pending operations
        super.cancel()
    }
    
    override func execute(completion: @escaping () -> Void) {
        state = .active
        annotate()
        group.notify(queue: queue) { [coreData] in
            DispatchQueue.main.async {
                coreData.saveNow() {
                    //  FIXME: Update entity ordinality
                    self.state = .completed
                }
            }
        }
    }
    
    private func annotate() {
        group.enter()
        coreData.performBackgroundChanges() { [identifier, group] context in
            if let data = try context.documents(withIdentifier: identifier).first?.imageData {
                self.annotateImage(data as Data)
            }
            group.leave()
        }
    }
    
    private func annotateImage(_ image: Data) {
        group.enter()
        service.annotateImage(image: image) { response in
            if let response = response {
                self.handleImageAnnotationsResponse(response)
            }
            self.group.leave()
        }
    }
    
    private func handleImageAnnotationsResponse(_ response: ImageAnnotationResponse) {
        processAnnotations(response.faceAnnotations, process: imageAnnotationProcessor(.face))
        processAnnotations(response.logoAnnotations, process: imageAnnotationProcessor(.logo))
        processAnnotations(response.codeAnnotations, process: processCodeAnnotation)
        processTextAnnotations(response.textAnnotations)
    }
    
    private func processAnnotations(_ annotations: [Annotation], process: (Annotation) -> Void) {
        for annotation in annotations {
            process(annotation)
        }
    }
    
    private func imageAnnotationProcessor(_ type: FragmentType) -> (Annotation) -> Void {
        return { annotation in
            // FIXME: Clip logo from source image according to bounding polygon. Import clipped image as image fragment.
        }
    }
    
    private func processCodeAnnotation(_ annotation: Annotation) {
        // FIXME: Import URLs, vCard and text from machine codes.
    }
    
    private func processTextAnnotations(_ annotations: [Annotation]) {
        guard let annotation = annotations.first else {
            return
        }
        let text = annotation.content
        group.enter()
        service.annotateText(text: text) { response in
            if let response = response {
                self.handleTextAnnotationsResponse(response)
            }
            self.group.leave()
        }
    }
    
    private func handleTextAnnotationsResponse(_ response: TextAnnotationResponse) {
        processEntities(response.personEntities, type: .person)
        processEntities(response.organizationEntities, type: .organization)
        processEntities(response.phoneEntities, type: .phoneNumber)
        processEntities(response.urlEntities, type: .url)
        processEntities(response.emailEntities, type: .email)
        processEntities(response.addressEntities, type: .address)
    }
    
    // MARK: Common
    
    private func processEntities(_ entities: [Entity], type: FragmentType) {
        for entity in entities {
            processEntity(entity, type: type)
        }
    }
    
    private func processEntity(_ entity: Entity, type: FragmentType) {
        group.enter()
        coreData.performBackgroundChanges() { [identifier, group] context in
            do {
                let fragment = Fragment(
                    type: type,
                    value: entity.content,
                    context: context
                )
                fragment.document = try context.documents(withIdentifier: identifier).first
                try context.save()
            }
            catch {
                print("Cannot import entity \(error)")
            }
            group.leave()
        }
    }
}
