//
//  ManagedListViewController.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/16.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import CoreData

enum Change {
    case update(IndexPath)
    case insert(IndexPath)
    case delete(IndexPath)
}

protocol ManagedListViewController {
    func applyChanges(_ changes: [Change])
}

class ManagedListController<ResultType : NSManagedObject> : NSObject, NSFetchedResultsControllerDelegate {
    
    typealias ChangeHandler = ([Change]) -> Void
    
    var numberOfSections: Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    private var changes = [Change]()
    
    private let fetchedResultsController: NSFetchedResultsController<ResultType>
    private let fetchRequest: NSFetchRequest<ResultType>
    private let context: NSManagedObjectContext
    private let changeHandler: ChangeHandler
    
    convenience init(fetchRequest: NSFetchRequest<ResultType>, context: NSManagedObjectContext, delegate: ManagedListViewController) {
        self.init(fetchRequest: fetchRequest, context: context) { changes in
            delegate.applyChanges(changes)
        }
    }
    
    required init(fetchRequest: NSFetchRequest<ResultType>, context: NSManagedObjectContext, changeHandler: @escaping ChangeHandler) {
        self.fetchRequest = fetchRequest
        self.context = context
        self.changeHandler = changeHandler
        self.fetchedResultsController = NSFetchedResultsController<ResultType>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        
        fetchedResultsController.delegate = self
        refresh()
    }
    
    //
    //
    //
    func refresh() {
        try! fetchedResultsController.performFetch()
    }
    
    //
    //
    //
    func numberOfItems(inSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    //
    //
    //
    func object(at indexPath: IndexPath) -> ResultType? {
        return fetchedResultsController.object(at: indexPath)
    }

    
    //
    //  Fetched results controller is about to make some changes. Initializes a change list to collect changes.
    //
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        changes.removeAll()
    }
    
    //
    //  Handle an incremental change from the fetched results controller. The changes are coalesced into an list and
    //  applied in a batch at the end of the changes.
    //
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch (type, indexPath, newIndexPath) {
        case (.delete, .some(let indexPath), _):
            changes.append(.delete(indexPath))
            
        case (.insert, _, .some(let newIndexPath)):
            changes.append(.insert(newIndexPath))
            
        case (.move, .some(let indexPath), .some(let newIndexPath)):
            changes.append(.delete(indexPath))
            changes.append(.insert(newIndexPath))
            
        case (.update, .some(let indexPath), _):
            changes.append(.update(indexPath))
            
        default:
            print("Unsupported update: \(type) \(indexPath) \(newIndexPath)")
        }
    }
    
    //
    //  Fetched results controller has finished making changes. Any collected changes are applied now in a batch
    //  operation on the collection view.
    //
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard self.changes.count > 0 else {
            return
        }
        let changes = self.changes
        self.changes.removeAll()
        changeHandler(changes)
    }
}

extension UITableViewController: ManagedListViewController {
    func applyChanges(_ changes: [Change]) {
        assert(Thread.isMainThread)
        tableView.beginUpdates()
        for change in changes {
            switch change {
            case .insert(let indexPath):
                tableView.insertRows(at: [indexPath], with: .automatic)
                
            case .delete(let indexPath):
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
            case .update(let indexPath):
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        tableView.endUpdates()
    }
}

extension UICollectionViewController: ManagedListViewController {
    func applyChanges(_ changes: [Change]) {
        assert(Thread.isMainThread)
        guard let collectionView = self.collectionView else {
            return
        }
        collectionView.performBatchUpdates({
            for change in changes {
                switch change {
                case .insert(let indexPath):
                    collectionView.insertItems(at: [indexPath])
                    
                case .delete(let indexPath):
                    collectionView.deleteItems(at: [indexPath])
                    
                case .update(let indexPath):
                    collectionView.reloadItems(at: [indexPath])
                }
            }
        }, completion: { (finished) in
        })
    }
}
