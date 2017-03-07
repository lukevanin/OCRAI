//
//  DocumentsViewController.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import CoreData

private let cameraSegue = "camera"
private let documentSegue = "document"

private let cellIdentifier = "DocumentCell"

protocol ImageSource: class {
    var selectedImageData: Data? {
        get
    }
}

class DocumentsViewController: UITableViewController {
    
    private lazy var coreData: CoreDataStack = {
        let instance = try! CoreDataStack(name: "OCRAI")
        instance.autosave(every: 30.0)
        return instance
    }()

    private lazy var listController: ManagedListController<Document> = {
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        return ManagedListController(
            fetchRequest: fetchRequest,
            context: self.coreData.mainContext,
            delegate: self
        )
    }()
    
    @IBOutlet weak var libraryButtonItem: UIBarButtonItem!
    @IBOutlet weak var cameraButtonItem: UIBarButtonItem!
    
    @IBAction func unwindToDocuments(_ segue: UIStoryboardSegue) {
        if let viewController = segue.source as? ImageSource {
            if let imageData = viewController.selectedImageData {
                importDocumentFromImage(data: imageData)
            }
        }
    }

    private func importDocumentFromImage(data: Data) {
        coreData.performBackgroundChanges() { [weak self] context in
            
            guard let `self` = self else {
                return
            }
            
            let document = Document(
                imageData: data,
                context: context
            )
            
            do {
                try context.save()

                DispatchQueue.main.async {
                    self.coreData.saveNow() { success in
                        if success {
                            self.performSegue(withIdentifier: documentSegue, sender: document.identifier!)
                        }
                    }
                }
            }
            catch {
                print("Cannot save document: \(error)")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DocumentViewController {
            if let identifier = sender as? String {
                viewController.documentIdentifier = identifier
            }
            else if let indexPath = tableView.indexPathForSelectedRow, let item = listController.object(at: indexPath) {
                viewController.documentIdentifier = item.identifier
            }
            viewController.coreData = coreData
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItems = [editButtonItem]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        listController.refresh()
        tableView.reloadData()
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    // MARK: Table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listController.numberOfItems(inSection: 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DocumentCell
        
        if let item = listController.object(at: indexPath), let imageData = item.imageData {
            
            let title = item.title
//            let color = item.primaryType.color
            cell.documentView.fragments = item.allFragments
            
            cell.titleLabel.text = title
            cell.titleLabel.isHidden = title?.isEmpty ?? true
//            cell.backgroundColor = color
            
            if let image = UIImage(data: imageData as Data) {
                cell.documentView.image = image
                cell.documentView.isHidden = false
                cell.placeholderImageView.isHidden = true
            }
            else {
                cell.documentView.image = nil
                cell.documentView.isHidden = true
                cell.placeholderImageView.isHidden = false
            }
        }
        
        return cell
    }
}
