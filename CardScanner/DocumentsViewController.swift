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

private let defaultPlaceholderText = "You don't have any images yet.\nAdd photos from your library or camera to get started."

protocol ImageSource: class {
    var selectedImageData: Data? {
        get
    }
}

extension DocumentsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        let fetchRequest: NSFetchRequest<Document>

        if searchController.isActive {
        
            var predicates = [NSPredicate]()

            if let query = searchController.searchBar.text, !query.isEmpty {
                placeholderLabel.text = "No matches found for \"\(query)\"."
                predicates.append(NSPredicate(format: "any fields.value contains[cd] %@", query))
            }
            else {
                placeholderLabel.text = "Enter text to search."
            }
            
            fetchRequest = Document.fetchRequest()
            fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
            fetchRequest.sortDescriptors = [
                NSSortDescriptor(key: "creationDate", ascending: false)
            ]
        }
        else {
            placeholderLabel.text = defaultPlaceholderText
            fetchRequest = defaultFetchRequest
        }
        
        self.fetchRequest = fetchRequest
    }
}

class DocumentsViewController: DocumentsBaseViewController {
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        return controller
    }()
    
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var libraryButtonItem: UIBarButtonItem!
    @IBOutlet weak var cameraButtonItem: UIBarButtonItem!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
    }
    
    @IBAction func unwindToDocuments(_ segue: UIStoryboardSegue) {
        if let viewController = segue.source as? ImageSource {
            if let imageData = viewController.selectedImageData {
                importDocumentFromImage(data: imageData)
            }
        }
    }

    private func importDocumentFromImage(data: Data) {
        
        guard let image = UIImage(data: data, scale: 1.0) else {
            return
        }

        let context = coreData.mainContext
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
                coreData.saveNow() { success in
                    if success {
                        self.performSegue(withIdentifier: documentSegue, sender: document)
                    }
                }
            }
        }
        catch {
            print("Cannot save document: \(error)")
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
        return UIImageEffects.imageByApplyingExtraLightEffect(to: image)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        cameraButtonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        libraryButtonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
}
