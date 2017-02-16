//
//  DocumentViewController.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class DocumentViewController: UITableViewController {

    var documentIdentifier: String!
    var coreData: CoreDataStack!
    
    @IBOutlet weak var headerImageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDocument()
        addCoreDataObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanDocumentIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeCoreDataObserver()
    }
    
    // MARK: Document
    
    private func loadDocument() {
        do {
            let document = try coreData.mainContext.documents(withIdentifier: documentIdentifier).first
            
            if let imageData = document?.imageData {
                headerImageView.image = UIImage(data: imageData as Data)
            }
        }
        catch {
            print("Cannot fetch document: \(error)")
        }
    }
    
    private func addCoreDataObserver() {
        
    }
    
    private func removeCoreDataObserver() {
        
    }
    
    private func scanDocumentIfNeeded() {
        
    }
}
