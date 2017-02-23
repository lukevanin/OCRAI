//
//  DocumentViewController.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Contacts

private let basicCellIdentifier = "BasicCell"
private let addressCellIdentifier = "AddressCell"
private let imageCellIdentifier = "ImageCell"

class DocumentViewController: UITableViewController {
    
    enum SectionType {
        case text(TextFragmentType)
        case image
    }
    
    class Section {
        let title: String
        let type: SectionType
        var values: [Any]
        
        init(title: String, type: SectionType, values: [Any]) {
            self.title = title
            self.type = type
            self.values = values
        }
        
        func updateOrdering() {
            for i in 0 ..< values.count {
                let value = values[i]
                
                switch value {
                    
                case let textFragment as TextFragment:
                    // FIXME: Ensure fragment type matches section type.
                    textFragment.ordinality = Int32(i)
                    
                default:
                    fatalError("Unknown fragment type")
                }
            }
        }
    }

    var documentIdentifier: String!
    var coreData: CoreDataStack!
    
    private lazy var scanner: ScannerService = {
        let factory = DefaultServiceFactory()
        return ScannerService(
            factory: factory,
            coreData: self.coreData
        )
    }()
    
    private var sections = [Section]()
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBAction func onScanAction(_ sender: Any) {
        if isEditing {
            isEditing = false
        }
        
        clearDocument() {
            DispatchQueue.main.async {
                self.scanDocument()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDocument()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.beginUpdates()
        
        if editing {
            // Edit mode.
            // Insert one additional row for each section.
            var indexPaths = [IndexPath]()
            for i in 0 ..< sections.count {
                let indexPath = IndexPath(row: sections[i].values.count, section: i)
                indexPaths.append(indexPath)
            }
            tableView.insertRows(at: indexPaths, with: .fade)
        }
        else {
            // Non-edit mode.
            // Remove additional row for each section.
            var indexPaths = [IndexPath]()
            for i in 0 ..< sections.count {
                let indexPath = IndexPath(row: sections[i].values.count, section: i)
                indexPaths.append(indexPath)
            }
            tableView.deleteRows(at: indexPaths, with: .fade)
        }
        
        tableView.endUpdates()
    }
    
    // MARK: Document
    
    private func clearDocument(completion: @escaping () -> Void) {
        sections.removeAll()
        tableView.reloadData()
        
        coreData.performBackgroundChanges { [documentIdentifier] (context) in
            
            let document = try context.documents(withIdentifier: documentIdentifier!).first
            
            if let fragments = document?.imageFragments?.allObjects as? [ImageFragment] {
                for fragment in fragments {
                    context.delete(fragment)
                }
            }
            
            if let fragments = document?.textFragments?.allObjects as? [TextFragment] {
                for fragment in fragments {
                    context.delete(fragment)
                }
            }
            
            if let addresses = document?.addresses?.allObjects as? [AddressFragment] {
                for address in addresses {
                    context.delete(address)
                }
            }
            
            do {
                try context.save()
            }
            catch {
                print("Cannot remove fragments from document: \(error)")
            }
            
            completion()
        }
    }
    
    private func loadDocument() {
        do {
            var sections = [Section]()
            let document = try coreData.mainContext.documents(withIdentifier: documentIdentifier).first
            
            if let imageData = document?.imageData {
                headerImageView.image = UIImage(data: imageData as Data)
            }

            // FIXME: Filter image fragments
//            if let imageFragments = document?.imageFragments?.allObjects {
//                sections.append(contentsOf: imageFragments)
//            }
            
            if let fragments = document?.textFragments?.allObjects as? [TextFragment] {
                
                func filterFragments(_ type: TextFragmentType) -> [TextFragment] {
                    return fragments
                        .filter() { $0.type == type }
                        .sorted() { $0.ordinality < $1.ordinality }
                }
                
                sections.append(Section(
                    title: "Person",
                    type: .text(.person),
                    values: filterFragments(.person)
                ))

                sections.append(Section(
                    title: "Organization",
                    type: .text(.organization),
                    values: filterFragments(.organization)
                ))
                
                sections.append(Section(
                    title: "Phone number",
                    type: .text(.phoneNumber),
                    values: filterFragments(.phoneNumber)
                ))

                sections.append(Section(
                    title: "Email",
                    type: .text(.email),
                    values: filterFragments(.email)
                ))
                
                sections.append(Section(
                    title: "URL",
                    type: .text(.url),
                    values: filterFragments(.url)
                ))
                
                sections.append(Section(
                    title: "Address",
                    type: .text(.address),
                    values: filterFragments(.address)
                ))
            }
            
            self.sections = sections
            tableView.reloadData()
        }
        catch {
            print("Cannot fetch document: \(error)")
        }
    }
    
    private func saveDocument() {
        
        // FIXME: Fetch and update fragments on background context to maintain synchronization.
        coreData.saveNow()
    }
    
    private func scanDocument() {
        scanner.scan(document: documentIdentifier) { (state) in
            DispatchQueue.main.async {
                self.handleScannerState(state)
            }
        }
    }
    
    private func handleScannerState(_ state: ScannerService.State) {
        switch state {
        case .pending:
            print("pending")
            
        case .active:
            print("active")
            scanButton.isHidden = true
            activityIndicatorView.startAnimating()
            
        case .completed:
            print("completed")
            scanButton.isHidden = false
            activityIndicatorView.stopAnimating()
            loadDocument()
        }
    }
    
    // MARK: Table view
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfItems = sections[section].values.count
        
        if isEditing {
            return numberOfItems + 1
        }
        else {
            return numberOfItems
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = sections[indexPath.section]
        
        if isEditing && (indexPath.row == section.values.count) {
            return self.tableView(tableView, cellForBlankTextFragmentAt: indexPath)
        }
        
        let fragment = section.values[indexPath.row]
        
        switch fragment {
            
        case let fragment as TextFragment:
            return self.tableView(tableView, cellForTextFragment:fragment, at: indexPath)
            
        case let fragment as ImageFragment:
            return self.tableView(tableView, cellForImageFragment:fragment, at: indexPath)
            
        case let fragment as AddressFragment:
            return self.tableView(tableView, cellForAddressFragment:fragment, at: indexPath)
            
        default:
            fatalError("Unknown fragment type: \(fragment)")
        }
    }
    
    private func tableView(_ tableView: UITableView, cellForBlankTextFragmentAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellIdentifier, for: indexPath) as! BasicFragmentCell
//        cell.contentTextField.text = "Add"
        return cell
    }
    
    private func tableView(_ tableView: UITableView, cellForTextFragment fragment: TextFragment, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellIdentifier, for: indexPath) as! BasicFragmentCell
        cell.contentTextField.text = fragment.value
        cell.showsReorderControl = true
        return cell
    }
    
    private func tableView(_ tableView: UITableView, cellForImageFragment fragment: ImageFragment, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageFragmentCell
        return cell
    }
    
    private func tableView(_ tableView: UITableView, cellForAddressFragment fragment: AddressFragment, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: addressCellIdentifier, for: indexPath) as! AddressFragmentCell
        cell.configure(fragment: fragment)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        let section = sections[indexPath.section]
        if indexPath.row == section.values.count {
            return false
        }
        else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let section = sections[indexPath.section]
        if indexPath.row == section.values.count {
            return .insert
        }
        else {
            return .delete
        }
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let sourceSection = sections[sourceIndexPath.section]
        let destinationSection = sections[proposedDestinationIndexPath.section]

        if !canMove(from: sourceSection.type, to: destinationSection.type) {
            return sourceIndexPath
        }
        
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
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSection = sections[sourceIndexPath.section]
        let destinationSection = sections[destinationIndexPath.section]
        let fragment = sourceSection.values.remove(at: sourceIndexPath.row)
        
        switch (fragment, destinationSection.type) {
        case (let textFragment as TextFragment, .text(let type)):
            textFragment.type = type

        default:
            fatalError("Unexpected fragment type change")
        }
        
        destinationSection.values.insert(fragment, at: destinationIndexPath.row)
        sourceSection.updateOrdering()
        destinationSection.updateOrdering()
        saveDocument()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    private func canMove(from: SectionType, to: SectionType) -> Bool {
        switch (from, to) {
        case (.image, .image):
            return true
        case (.text(_), .text(_)):
            return true
        default:
            return false
        }
    }
}
