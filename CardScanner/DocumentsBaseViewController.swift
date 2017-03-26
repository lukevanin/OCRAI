//
//  DocumentsSearchViewController.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/26.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import CoreData

private let cellIdentifier = "DocumentCell"

extension DocumentsBaseViewController: ManagedListControllerDelegate {
    func applyChanges(_ changes: [Change]) {
        tableView.applyChanges(changes)
        updateViewState()
    }
}

class DocumentsBaseViewController: UITableViewController {
    
    lazy var defaultFetchRequest: NSFetchRequest<Document> = {
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        return fetchRequest
    }()
    
    var fetchRequest: NSFetchRequest<Document>? {
        didSet {
            self.invalidateListController()
        }
    }
    
    private var listController: ManagedListController<Document>! {
        didSet {
            if isViewLoaded {
                tableView?.reloadData()
                updateViewState()
            }
        }
    }
    
    @IBOutlet weak var emptyContentPlaceholderView: UIView!
    
    private func invalidateListController() {
        self.listController = ManagedListController(
            fetchRequest: fetchRequest ?? defaultFetchRequest,
            context: coreData.mainContext,
            delegate: self
        )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DocumentViewController {
            
            let document: Document
            
            if let item = sender as? Document {
                // Document originated from import.
                document = item
            }
            else if let indexPath = tableView.indexPathForSelectedRow, let item = listController.object(at: indexPath) {
                // Tapped on existing document.
                document = item
            }
            else {
                return
            }
            
            viewController.document = document
            viewController.coreData = coreData
            viewController.scanner = documentManager.createScanner(forDocument: document)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [editButtonItem]
        fetchRequest = defaultFetchRequest
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listController.refresh()
        tableView.reloadData()
        updateViewState()
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    // MARK: Table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listController.numberOfItems(inSection: 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DocumentCell
        
        if let document = listController.object(at: indexPath) {
            let scanner = documentManager.getScanner(forDocument: document)
            cell.configure(with: document, scanner: scanner)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let document = listController.object(at: indexPath) {
            presentActionsAlertForDocument(document: document)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
            
        case .delete:
            deleteItem(at: indexPath)
            
        default:
            break
        }
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        
        guard let document = listController.object(at: indexPath) else {
            return
        }
        
        documentManager.removeScanner(forDocument: document)
        
        let context = coreData.mainContext
        context.delete(document)
        
        coreData.saveNow()
    }
    
    // MARK: View state
    
    fileprivate func updateViewState() {
        if tableView.numberOfRows(inSection: 0) == 0 {
            // Table is empty
            navigationItem.rightBarButtonItem = nil
            tableView.setEditing(false, animated: true)
            tableView.backgroundView = emptyContentPlaceholderView
        }
        else {
            // Table has content.
            navigationItem.rightBarButtonItem = editButtonItem
            tableView.backgroundView = nil
        }
    }
}
