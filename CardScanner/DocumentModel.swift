//
//  DocumentModel.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import CoreData

protocol DocumentModelDelegate: class {
    func documentModel(model: DocumentModel, didUpdateWithChanges changes: DocumentModel.Changes)
}

extension UITableView {
    func applyChanges(_ changes: DocumentModel.Changes) {
        assert(Thread.isMainThread)
        
        if changes.hasIncrementalChanges {
            beginUpdates()
            
            if let sections = changes.deletedSections, sections.count > 0 {
                deleteSections(sections, with: .fade)
            }
            
            if let sections = changes.insertedSections, sections.count > 0 {
                insertSections(sections, with: .fade)
            }
            
            if let indexPaths = changes.deletedRows, indexPaths.count > 0 {
                deleteRows(at: indexPaths, with: .fade)
            }
            
            if let indexPaths = changes.insertedRows, indexPaths.count > 0 {
                insertRows(at: indexPaths, with: .fade)
            }
            
            if let indexPaths = changes.updatedRows, indexPaths.count > 0 {
                deleteRows(at: indexPaths, with: .fade)
                insertRows(at: indexPaths, with: .fade)
            }
            
            if let moves = changes.movedRows, moves.count > 0 {
                for (from, to) in moves {
                    moveRow(at: from, to: to)
                }
            }
                
            endUpdates()
        }
        else {
            reloadData()
        }
    }
}

class DocumentModel {
    
    struct Changes {
        let hasIncrementalChanges: Bool
        let insertedSections: IndexSet?
        let deletedSections: IndexSet?
        let insertedRows: [IndexPath]?
        let deletedRows: [IndexPath]?
        let updatedRows: [IndexPath]?
        let movedRows: [(IndexPath, IndexPath)]?
        
        init(
            hasIncrementalChanges: Bool,
            insertedSections: IndexSet? = nil,
            deletedSections: IndexSet? = nil,
            insertedRows: [IndexPath]? = nil,
            deletedRows: [IndexPath]? = nil,
            updatedRows: [IndexPath]? = nil,
            movedRows: [(IndexPath, IndexPath)]? = nil
            ) {
            self.hasIncrementalChanges = hasIncrementalChanges
            self.insertedSections = insertedSections
            self.deletedSections = deletedSections
            self.insertedRows = insertedRows
            self.deletedRows = deletedRows
            self.updatedRows = updatedRows
            self.movedRows = movedRows
        }
    }
    
    struct Action {
        fileprivate typealias Action = () -> Void
        
        let title: String
        fileprivate let action: Action
        
        fileprivate init(title: String, action: @escaping Action) {
            self.title = title
            self.action = action
        }
        
        func execute() {
            action()
        }
    }
    
    private class Section {
        let title: String
        let actions: [Action]
        var objects: [NSManagedObject]
        
        init(title: String, objects: [NSManagedObject], actions: [Action]) {
            self.title = title
            self.objects = objects
            self.actions = actions
        }
        
        @discardableResult func remove(at: Int) -> NSManagedObject {
            let output = objects.remove(at: at)
            return output
        }
        
        func append(_ fragment: NSManagedObject) -> Int {
            let index = objects.count
            insert(fragment, at: index)
            return index
        }
        
        func insert(_ fragment: NSManagedObject, at: Int) {
            objects.insert(fragment, at: at)
        }
    }
    
    weak var delegate: DocumentModelDelegate?
    
    var isEditing: Bool = false {
        didSet {
            guard isEditing != oldValue else {
                return
            }
            
            var indexPaths = [IndexPath]()
            
            for s in 0 ..< sections.count {
                let section = sections[s]
                let o = section.objects.count
                let a = section.actions.count
                
                for i in 0 ..< a {
                    let indexPath = IndexPath(row: o + i, section: s)
                    indexPaths.append(indexPath)
                }
            }
            
            let changes: Changes
                
            if isEditing {
                changes = Changes(
                    hasIncrementalChanges: true,
                    insertedRows: indexPaths
                )
            }
            else {
                changes = Changes(
                    hasIncrementalChanges: true,
                    deletedRows: indexPaths
                )
            }
            notify(with: changes)
        }
    }
    
    var totalFragments: Int {
        var count = 0
        for i in 0 ..< numberOfSections {
            count += numberOfRowsInSection(i)
        }
        return count
    }
    
    var numberOfSections: Int {
        return sections.count
    }

    private var sections = [Section]()
    
    private let document: Document
    private let coreData: CoreDataStack
    
    init(document: Document, coreData: CoreDataStack) {
        self.document = document
        self.coreData = coreData
        fetch()
    }
    
    func fetch() {
        
        var deletedSectionIndices = IndexSet()
        var insertedSectionIndices = IndexSet()
        var insertedIndexPaths = [IndexPath]()
        
        for i in 0 ..< sections.count {
            deletedSectionIndices.insert(i)
        }
        
        sections = makeSections()
        
        for i in 0 ..< sections.count {
            insertedSectionIndices.insert(i)
            let section = sections[i]
            for j in 0 ..< section.objects.count {
                let indexPath = IndexPath(item: j, section: i)
                insertedIndexPaths.append(indexPath)
            }
        }
        
        let changes = Changes(
            hasIncrementalChanges: true,
            insertedSections: insertedSectionIndices,
            deletedSections: deletedSectionIndices,
            insertedRows: insertedIndexPaths
        )
        
        notify(with: changes)

    }
    
    private func makeSections() -> [Section] {
        var sections = [Section]()
        
        for fieldType in FieldType.all {
            sections.append(makeSection(sections.count, type: fieldType))
        }
        
        sections.append(makeAddressSection(sections.count))
        
        // FIXME: Add images
        // FIXME: Add dates
//        return sections.filter { $0.values.count > 0 }
        return sections
    }
    
    private func makeSection(_ section: Int, type: FieldType) -> Section {
        let title = String(describing: type.description)
        let objects = document.fields(ofType: type)
        let action = Action(title: "Add \(title)") { [weak self, document, coreData] in
            let context = coreData.mainContext
            let field = Field(type: type, value: "", ordinality: 0, context: context)
            field.document = document
            self?.insert(value: field, in: section)
        }
        return Section(title: title, objects: objects, actions: [action])
    }
    
    private func makeAddressSection(_ section: Int) -> Section {
        let title = "Address"
        let objects = document.allPostalAddresses
        let action = Action(title: "Add \(title)") { [weak self, document, coreData] in
            let context = coreData.mainContext
            let field = PostalAddress(address: nil, location: nil, context: context)
            field.document = document
            self?.insert(value: field, in: section)
        }
        return Section(title: title, objects: objects, actions: [action])
    }
    
    
    // MARK: Observer
    
    private func notify(with changes: Changes) {
        delegate?.documentModel(model: self, didUpdateWithChanges: changes)
    }


    // MARK: Query
    
    func titleForSection(at index: Int) -> String {
        return sections[index].title
    }
    
    func numberOfRowsInSection(_ index: Int) -> Int {
        let section = sections[index]
        let objectCount = section.objects.count
        let actionCount = isEditing ? section.actions.count : 0
        return objectCount + actionCount
    }
    
    func fragment(at indexPath: IndexPath) -> Any {
        let section = sections[indexPath.section]
        
        if indexPath.row < section.objects.count {
            return section.objects[indexPath.row]
        }
        else {
            return section.actions[indexPath.row - section.objects.count]
        }
    }
    
    func performAction(at indexPath: IndexPath) {
        guard let action = fragment(at: indexPath) as? Action else {
            return
        }
        action.execute()
    }

    
    // MARK: Modify
    
    func save() {
        coreData.saveNow()
    }

    func clear() {
        
        var sectionIndices = IndexSet()
        var indexPaths = [IndexPath]()
        var fragments = [NSManagedObject]()
        
        for i in 0 ..< sections.count {
            let section = sections[i]
            let count = section.objects.count
            
            for j in 0 ..< count {
                let indexPath = IndexPath(row: j, section: i)
                indexPaths.append(indexPath)
                
                let fragment = self.fragment(at: indexPath)
                
                if let object = fragment as? NSManagedObject {
                    fragments.append(object)
                }
            }
            
            sectionIndices.insert(i)
        }
        
        sections.removeAll()

        let context = coreData.mainContext
        for fragment in fragments {
            context.delete(fragment)
        }
        
        save()
        
        let changes = Changes(
            hasIncrementalChanges: true,
            deletedSections: sectionIndices,
            deletedRows: indexPaths
        )
        notify(with: changes)
    }
    
    func delete(at indexPaths: [IndexPath]) {
        
        guard indexPaths.count > 0 else {
            return
        }

        let context = coreData.mainContext
        
        for indexPath in indexPaths {
            let section = sections[indexPath.section]
            let fragment = section.remove(at: indexPath.row)
            context.delete(fragment)
        }
        
        save()
        
        let changes = Changes(
            hasIncrementalChanges: true,
            deletedRows: indexPaths
        )
        notify(with: changes)
    }
    
    private func insert(value: NSManagedObject, in sectionIndex: Int) {
        let section = sections[sectionIndex]
        let index = section.append(value)
        
        save()
        
        let indexPath = IndexPath(row: index, section: sectionIndex)

        let changes = Changes(
            hasIncrementalChanges: true,
            insertedRows: [indexPath]
        )
        notify(with: changes)
    }
    
    func cleanup() {
        
        var indexPaths = [IndexPath]()
        
        for s in 0 ..< sections.count {
            let section = sections[s]
            var keepObjects = [NSManagedObject]()
            
            for v in 0 ..< section.objects.count {
                let object = section.objects[v]
                let indexPath = IndexPath(row: v, section: s)
                var isEmpty = false
                
                // FIXME: Create protocol with isEmpty property. Make Field and PostalAddress conformant.
                
                if let field = object as? Field {
                    isEmpty = field.value?.isEmpty ?? true
                }
                else if let field = object as? PostalAddress {
                    let isStreetEmpty = field.street?.isEmpty ?? true
                    let isCityEmpty = field.city?.isEmpty ?? true
                    let isCodeEmpty = field.postalCode?.isEmpty ?? true
                    let isCountryEmpty = field.country?.isEmpty ?? true
                    isEmpty = isStreetEmpty && isCityEmpty && isCodeEmpty && isCountryEmpty
                }
                
                if isEmpty {
                    indexPaths.append(indexPath)
                }
                else {
                    keepObjects.append(object)
                }
            }
            
            section.objects = keepObjects
        }
        
        let changes = Changes(
            hasIncrementalChanges: true,
            deletedRows: indexPaths
        )
        notify(with: changes)
    }
}
