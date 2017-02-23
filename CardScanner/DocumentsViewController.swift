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
        return try! ManagedListController(
            fetchRequest: fetchRequest,
            context: self.coreData.mainContext,
            delegate: self
        )
    }()
    
    @IBAction func onAddAction(_ sender: Any) {
        let image = UIImage(named: "card-sample-2")!
        let data = UIImageJPEGRepresentation(image, 1.0)
        importDocumentFromImage(data: data!)
    }
    
    @IBAction func exitToDocuments(_ sender: UIStoryboardSegue) {
        if let viewController = sender.source as? CameraViewController {
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
                    self.coreData.saveNow() {
                        self.performSegue(withIdentifier: documentSegue, sender: document.identifier!)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: Table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listController.numberOfItems(inSection: 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DocumentCell
        
        if let item = listController.object(at: indexPath), let imageData = item.imageData {
            if let image = UIImage(data: imageData as Data) {
                cell.pictureImageView.image = image
                cell.pictureImageView.isHidden = false
                cell.placeholderImageView.isHidden = true
            }
            else {
                cell.pictureImageView.isHidden = true
                cell.placeholderImageView.isHidden = false
            }
        }
        
        return cell
    }
}
