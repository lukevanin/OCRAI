//
//  DocumentViewModel.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

protocol DocumentViewModelDelegate: class {
    func documentModel(model: DocumentViewModel, didUpdateWithChanges changes: DocumentViewModel.Changes)
}

extension UITableView {
    func applyChanges(_ changes: DocumentViewModel.Changes) {
        assert(Thread.isMainThread)
        if changes.hasIncrementalChanges {
            beginUpdates()
            
            if let sections = changes.deletedSections {
                deleteSections(sections, with: .top)
            }
            
            if let sections = changes.insertedSections {
                insertSections(sections, with: .bottom)
            }
            
            if let indexPaths = changes.deletedRows {
                deleteRows(at: indexPaths, with: .top)
            }
            
            if let indexPaths = changes.insertedRows {
                insertRows(at: indexPaths, with: .bottom)
            }
            
            if let indexPaths = changes.updatedRows {
                deleteRows(at: indexPaths, with: .automatic)
                insertRows(at: indexPaths, with: .automatic)
            }
            
            if let moves = changes.movedRows {
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

class DocumentViewModel {
    
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
        let type: FragmentType
        var values: [Fragment]
        
        init(title: String, type: FragmentType, values: [Fragment]) {
            self.title = title
            self.type = type
            self.values = values
        }
        
        @discardableResult func remove(at: Int) -> Fragment {
            let output = values.remove(at: at)
            updateOrdering(from: at)
            return output
        }
        
        func append(_ fragment: Fragment) {
            insert(fragment, at: values.count)
        }
        
        func insert(_ fragment: Fragment, at: Int) {
            fragment.type = type
            fragment.ordinality = Int32(at)
            values.insert(fragment, at: at)
            updateOrdering(from: at)
        }
        
        func updateOrdering() {
            updateOrdering(from: 0)
        }
        
        func updateOrdering(from: Int) {
            for i in from ..< values.count {
                values[i].ordinality = Int32(i)
            }
        }
    }
    
    weak var delegate: DocumentViewModelDelegate?
    
    var totalFragments: Int {
        var count = 0
        for index in activeSections {
            let section = sections[index];
            count += section.values.count
        }
        return count
    }
    
    var numberOfSections: Int {
        return activeSections.count
    }
    
    var includeEmptySections = false {
        didSet {
            if includeEmptySections != oldValue {
                updateActiveSections()
            }
        }
    }

    private var sections = [Section]()
    private var activeSections = [Int]()
    
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
        
        for i in 0 ..< activeSections.count {
            deletedSectionIndices.insert(i)
        }
        
        sections = makeSections()
        activeSections = makeActiveSections()
        
        for i in 0 ..< activeSections.count {
            insertedSectionIndices.insert(i)
            let section = sections[activeSections[i]]
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
        sections.append(makeSection(type: .person))
        sections.append(makeSection(type: .organization))
        sections.append(makeSection(type: .phoneNumber))
        sections.append(makeSection(type: .email))
        sections.append(makeSection(type: .url))
        sections.append(makeSection(type: .address))
        // FIXME: Add images
        // FIXME: Add dates
        return sections
    }
    
    private func makeSection(type: FragmentType) -> Section {
        return Section(
            title: type.description,
            type: type,
            values: document.fragments(ofType: type)
        )
    }
    
    private func makeActiveSections() -> [Int] {
        var output = [Int]()
        for i in 0 ..< sections.count {
            let section = sections[i]
            if section.values.count > 0 {
                output.append(i)
            }
        }
        return output
    }
    
    private func updateActiveSections() {
        if includeEmptySections {
            insertEmptySections()
        }
        else {
            removeEmptySections()
        }
    }
    
    private func insertEmptySections() {
        activeSections.removeAll()
        var indexPaths = [IndexPath]()
        var sectionIndices = IndexSet()
        for i in 0 ..< sections.count {
            let section = sections[i]
            activeSections.append(i)
            
            let count = section.values.count
            
            if count == 0 {
                sectionIndices.insert(i)
            }
            else {
                
            }
            
            let indexPath = IndexPath(row: count, section: i)
            indexPaths.append(indexPath)
        }
        
        let changes = Changes(
            hasIncrementalChanges: true,
            insertedSections: sectionIndices,
            deletedSections: nil,
            insertedRows: indexPaths,
            deletedRows: nil,
            updatedRows: nil,
            movedRows: nil
        )
        
        notify(with: changes)
    }
    
    private func removeEmptySections() {
        activeSections.removeAll()
        var indexPaths = [IndexPath]()
        var sectionIndices = IndexSet()
        for i in 0 ..< sections.count {
            let section = sections[i]
            let count = section.values.count
            
            if count == 0 {
                sectionIndices.insert(i)
            }
            else {
                activeSections.append(i)
            }
            
            let indexPath = IndexPath(row: count, section: i)
            indexPaths.append(indexPath)
        }

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
    
    // MARK: Observer
    
    private func notify(with changes: Changes) {
        delegate?.documentModel(model: self, didUpdateWithChanges: changes)
    }


    // MARK: Query
    
    func typeForSection(at index: Int) -> FragmentType {
        return section(at: index).type
    }
    
    func titleForSection(at index: Int) -> String {
        return section(at: index).title
    }
    
    func numberOfRowsInSection(_ index: Int) -> Int {
        return section(at: index).values.count
    }
    
    func fragment(at indexPath: IndexPath) -> Fragment {
        return section(at: indexPath.section).values[indexPath.row]
    }
    
    private func section(at index: Int) -> Section {
        return sections[activeSections[index]]
    }
    
    // MARK: Modify
    
    func save() {
        coreData.saveNow()
    }

    func clear() {
        
        var sectionIndices = IndexSet()
        
        for i in 0 ..< activeSections.count {
            sectionIndices.insert(i)
        }
        
        sections.removeAll()
        activeSections.removeAll()

        let context = coreData.mainContext
        let fragments = document.allFragments
        for fragment in fragments {
            context.delete(fragment)
        }
        
        save()
        
        notify(with:
            Changes(
                hasIncrementalChanges: true,
                insertedSections: nil,
                deletedSections: sectionIndices,
                insertedRows: nil,
                deletedRows: nil,
                updatedRows: nil,
                movedRows: nil
            )
        )
    }
    
    func delete(at indexPath: IndexPath) {
        let section = self.section(at: indexPath.section)
        let context = coreData.mainContext
        let fragment = section.remove(at: indexPath.row)
        context.delete(fragment)
        
        save()
        
        notify(with:
            Changes(
                hasIncrementalChanges: true,
                insertedSections: nil,
                deletedSections: nil,
                insertedRows: nil,
                deletedRows: [indexPath],
                updatedRows: nil,
                movedRows: nil
            )
        )
    }
    
    func update(value: String?, at indexPath: IndexPath) {
        let section = self.section(at: indexPath.section)
        let fragment = section.values[indexPath.row]
        fragment.value = value
        
        save()

        notify(with:
            Changes(
                hasIncrementalChanges: true,
                insertedSections: nil,
                deletedSections: nil,
                insertedRows: nil,
                deletedRows: nil,
                updatedRows: [indexPath],
                movedRows: nil
            )
        )
    }
    
    func insert(value: String?, at indexPath: IndexPath) {
        let section = self.section(at: indexPath.section)
        let context = coreData.mainContext
        let fragment = Fragment(type: section.type, value: value, context: context)
        fragment.document = document
        section.append(fragment)
        
        save()
        
        notify(with:
            Changes(
                hasIncrementalChanges: true,
                insertedSections: nil,
                deletedSections: nil,
                insertedRows: [indexPath],
                deletedRows: nil,
                updatedRows: nil,
                movedRows: nil
            )
        )
    }
    
    func targetIndexPathForMove(from sourceIndexPath: IndexPath, to proposedDestinationIndexPath: IndexPath) -> IndexPath {
//        let sourceSection = section(at: sourceIndexPath.section)
        let destinationSection = section(at: proposedDestinationIndexPath.section)
        
        let limit: Int
        
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            // Moving within same section
            limit = destinationSection.values.count - 1
        }
        else {
            // Moving to a different section
            limit = destinationSection.values.count
        }
        
        let index = min(limit, proposedDestinationIndexPath.row)
        return IndexPath(row: index, section: proposedDestinationIndexPath.section)
    }

    func move(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSection = self.section(at: sourceIndexPath.section)
        let destinationSection = self.section(at: destinationIndexPath.section)
        let fragment = sourceSection.values.remove(at: sourceIndexPath.row)
        fragment.type = destinationSection.type
        destinationSection.values.insert(fragment, at: destinationIndexPath.row)
        sourceSection.updateOrdering()
        destinationSection.updateOrdering()
        
        save()
        
        notify(with: Changes(
            hasIncrementalChanges: true,
            insertedSections: nil,
            deletedSections: nil,
            insertedRows: nil,
            deletedRows: nil,
            updatedRows: nil,
            movedRows: [(sourceIndexPath, destinationIndexPath)]
        ))
    }
}
