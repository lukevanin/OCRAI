//
//  DocumentModel.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/12.
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
    
    private class Section {
        let title: String
        var values: [NSManagedObject]
        
        init(title: String, values: [NSManagedObject]) {
            self.title = title
            self.values = values
        }
        
        @discardableResult func remove(at: Int) -> NSManagedObject {
            let output = values.remove(at: at)
            return output
        }
        
        func append(_ fragment: NSManagedObject) {
            insert(fragment, at: values.count)
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
        return sections.filter { $0.values.count > 0 }
    }
    
    private func makeSection(type: FieldType) -> Section {
        return Section(
            title: String(describing: type.description),
            values: document.fields(ofType: type)
        )
    }
    
    private func makeAddressSection() -> Section {
        return Section(
            title: "Address",
            values: document.allPostalAddresses
        )
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
        
        for i in 0 ..< sections.count {
            let section = self.section(at: i)
            let count = section.values.count
            
            for j in 0 ..< count {
                let indexPath = IndexPath(row: j, section: i)
                indexPaths.append(indexPath)
            }
            
            sectionIndices.insert(i)
        }
        
        sections.removeAll()

        let context = coreData.mainContext
        let fragments = document.allFields
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
    
    func delete(at indexPath: IndexPath) {
        
        let section = self.section(at: indexPath.section)
        let fragment = section.remove(at: indexPath.row)
        var sectionIndices: IndexSet?
        
        if section.values.count == 0 {
            sections.remove(at: indexPath.section)
            sectionIndices = IndexSet(integer: indexPath.section)
        }
        
        let context = coreData.mainContext
        context.delete(fragment)
        
        save()
        
        let changes = Changes(
            hasIncrementalChanges: true,
            insertedSections: nil,
            deletedSections: sectionIndices,
            insertedRows: nil,
            deletedRows: [indexPath],
            updatedRows: nil,
            movedRows: nil
        )
        notify(with: changes)
    }
}
