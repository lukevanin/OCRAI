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
    @IBOutlet weak var emptyContentPlaceholderView: UIView!
    
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
            
            guard let image = UIImage(data: data, scale: 1.0) else {
                return
            }
                
            let document = Document(
                imageData: data,
                imageSize: image.size,
                context: context
            )

            // Render thumbnail
            let thumbnailImage = self.makeThumbnail(from: image)
            document.thumbnailImageData = UIImagePNGRepresentation(thumbnailImage) as NSData?
            
            // Render blurred thumbnail
            let blurredImage = self.makeBlurredImage(from: image)
            document.blurredImageData = UIImagePNGRepresentation(blurredImage) as NSData?
            
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
    
    private func makeThumbnail(from image: UIImage) -> UIImage {
        let width = UIScreen.main.bounds.size.width * UIScreen.main.scale
        let height = width * 0.75
        let size = CGSize(
            width: width,
            height: height
        )
        return image.resize(size: size)
    }
    
    private func makeBlurredImage(from image: UIImage) -> UIImage {
//        return UIImageEffects.imageByApplyingLightEffect(to: image)
        return UIImageEffects.imageByApplyingExtraLightEffect(to: image)
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
        updateViewState()
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    // MARK: Table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listController.numberOfItems(inSection: 0)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DocumentCell
        
        if let item = listController.object(at: indexPath) {
            
            cell.documentView?.document = item
            
            if let imageData = item.thumbnailImageData, let image = UIImage(data: imageData as Data, scale: UIScreen.main.scale) {
                cell.documentView?.image = image
                cell.documentView?.isHidden = false
                cell.placeholderImageView?.isHidden = true
            }
            else {
                cell.documentView?.image = nil
                cell.documentView?.isHidden = true
                cell.placeholderImageView?.isHidden = false
            }
            
            let titles = item.titles
            
            if titles.count > 0 {
                cell.titleLabel?.text = titles[0]
                
                if titles.count > 1 {
                    cell.subtitleLabel?.text = titles[1]
                }
            }
            
            //
            if let imageData = item.blurredImageData, let image = UIImage(data: imageData as Data, scale: UIScreen.main.scale) {
//                cell.backgroundImageView.image = image
            }
            else {
//                cell.backgroundImageView.image = nil
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let document = listController.object(at: indexPath) {
            document.presentActions(from: self)
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
        
        guard let document = listController.object(at: indexPath), let identifier = document.identifier else {
            return
        }
        
        coreData.performBackgroundChanges() { [weak self] context in
            guard let document = try context.documents(withIdentifier: identifier).first else {
                return
            }
            
            context.delete(document)
            try context.save()
        }
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

extension DocumentsViewController: ManagedListControllerDelegate {
    func applyChanges(_ changes: [Change]) {
        tableView.applyChanges(changes)
        updateViewState()
    }
}
