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
    }
    
    private typealias InsertValueIntoSection = () -> NSManagedObject
    
    private class Section {
        let title: String
        let insert: InsertValueIntoSection
        var values: [NSManagedObject]
        
        init(title: String, values: [NSManagedObject], insert: @escaping InsertValueIntoSection) {
            self.title = title
            self.insert = insert
            self.values = values
        }
        
        @discardableResult func remove(at: Int) -> NSManagedObject {
            let output = values.remove(at: at)
            return output
        }
        
        func append(_ fragment: NSManagedObject) {
            insert(fragment, at: values.count)
        }
        
        func create() -> Int {
            let value = insert()
            let index = values.count
            values.append(value)
            return index
        }
        
        func insert(_ fragment: NSManagedObject, at: Int) {
            values.insert(fragment, at: at)
        }
    }
    
    weak var delegate: DocumentModelDelegate?
    
    var totalFragments: Int {
        var count = 0
        for section in sections {
            count += section.values.count
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
            for j in 0 ..< section.values.count {
                let indexPath = IndexPath(item: j, section: i)
                insertedIndexPaths.append(indexPath)
            }
        }
        
        let changes = Changes(
            hasIncrementalChanges: true,
            insertedSections: insertedSectionIndices,
            deletedSections: deletedSectionIndices,
            insertedRows: insertedIndexPaths,
            deletedRows: nil,
            updatedRows: nil,
            movedRows: nil
        )
        
        notify(with: changes)

    }
    
    private func makeSections() -> [Section] {
        var sections = [Section]()
        
        for fieldType in FieldType.all {
            sections.append(makeSection(type: fieldType))
        }
        
        sections.append(makeAddressSection())
        
        // FIXME: Add images
        // FIXME: Add dates
//        return sections.filter { $0.values.count > 0 }
        return sections
    }
    
    private func makeSection(type: FieldType) -> Section {
        let title = String(describing: type.description)
        let values = document.fields(ofType: type)
        return Section(title: title, values: values) { [document, coreData] in
            let context = coreData.mainContext
            let field = Field(type: type, value: "", ordinality: 0, context: context)
            field.document = document
            return field
        }
    }
    
    private func makeAddressSection() -> Section {
        let values = document.allPostalAddresses
        return Section(title: "Address", values: values) { [document, coreData] in
            let context = coreData.mainContext
            let field = PostalAddress(address: nil, location: nil, context: context)
            field.document = document
            return field
        }
    }
    
    
    // MARK: Observer
    
    private func notify(with changes: Changes) {
        delegate?.documentModel(model: self, didUpdateWithChanges: changes)
    }


    // MARK: Query
    
    func titleForSection(at index: Int) -> String {
        return section(at: index).title
    }
    
    func numberOfRowsInSection(_ index: Int) -> Int {
        return section(at: index).values.count
    }
    
    func fragment(at indexPath: IndexPath) -> Any {
        return section(at: indexPath.section).values[indexPath.row]
    }
    
    private func section(at index: Int) -> Section {
        return sections[index]
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
            let section = self.section(at: i)
            let count = section.values.count
            
            for j in 0 ..< count {
                let indexPath = IndexPath(row: j, section: i)
                indexPaths.append(indexPath)
                
                let value = section.values[j]
                fragments.append(value)
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
            insertedSections: nil,
            deletedSections: sectionIndices,
            insertedRows: nil,
            deletedRows: indexPaths,
            updatedRows: nil,
            movedRows: nil
        )
        notify(with: changes)
    }
    
    func delete(at indexPaths: [IndexPath]) {
        
        guard indexPaths.count > 0 else {
            return
        }

        let context = coreData.mainContext
        
        for indexPath in indexPaths {
            let section = self.section(at: indexPath.section)
            let fragment = section.remove(at: indexPath.row)
            context.delete(fragment)
        }
        
        save()
        
        let changes = Changes(
            hasIncrementalChanges: true,
            insertedSections: nil,
            deletedSections: nil,
            insertedRows: nil,
            deletedRows: indexPaths,
            updatedRows: nil,
            movedRows: nil
        )
        notify(with: changes)
    }
    
    func insert(in sectionIndex: Int) {
        let section = self.section(at: sectionIndex)
        let index = section.create()
        
        save()
        
        let indexPath = IndexPath(row: index, section: sectionIndex)

        let changes = Changes(
            hasIncrementalChanges: true,
            insertedSections: nil,
            deletedSections: nil,
            insertedRows: [indexPath],
            deletedRows: nil,
            updatedRows: nil,
            movedRows: nil
        )
        notify(with: changes)
    }
    
    func cleanup() {
        
        var indexPaths = [IndexPath]()
        
        for s in 0 ..< sections.count {
            let section = sections[s]
            var values = [NSManagedObject]()
            
            for v in 0 ..< section.values.count {
                let value = section.values[v]
                let indexPath = IndexPath(row: v, section: s)
                var isEmpty = false
                
                // FIXME: Create protocol with isEmpty property. Make Field and PostalAddress conformant.
                
                if let field = value as? Field {
                    isEmpty = field.value?.isEmpty ?? true
                }
                else if let field = value as? PostalAddress {
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
                    values.append(value)
                }
            }
            
            section.values = values
        }
        
        let changes = Changes(
            hasIncrementalChanges: true,
            insertedSections: nil,
            deletedSections: nil,
            insertedRows: nil,
            deletedRows: indexPaths,
            updatedRows: nil,
            movedRows: nil
        )
        notify(with: changes)
    }
}
