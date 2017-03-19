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

class DocumentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TextCellDelegate {

    var documentIdentifier: String!
    var coreData: CoreDataStack!
    
    private lazy var scanner: ScannerService = {
        let factory = DefaultServiceFactory()
        return ScannerService(
            factory: factory,
            coreData: self.coreData
        )
    }()
    
    private var document: Document?
    private var model: DocumentViewModel?

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var documentView: DocumentView!
    @IBOutlet weak var activityOverlayView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var scanButtonItem: UIBarButtonItem!
    @IBOutlet weak var actionsButtonItem: UIBarButtonItem!
    @IBOutlet weak var emptyContentPlaceholderView: UIView!
    
    @IBAction func onActionsAction(_ sender: Any) {
        guard let document = document else {
            return
        }
        presentActionsAlertForDocument(document: document)
    }
    
    @IBAction func onScanAction(_ sender: Any) {
        if isEditing {
            setEditing(false, animated: true)
        }

        promptToScan() { [weak self] shouldScan in
            guard shouldScan else {
                return
            }
            self?.clearDocument()
            self?.scanDocument()
        }
    }
    
    private func promptToScan(completion: @escaping (Bool) -> Void) {
        
        let totalFragments = model?.totalFragments ?? 0
        
        if totalFragments == 0 {
            completion(true)
            return
        }
        
        let controller = UIAlertController(
            title: nil,
            message: "Do you want to overwrite existing content?",
            preferredStyle: .alert
        )
        
        controller.addAction(
            UIAlertAction(
                title: "Overwrite",
                style: .destructive,
                handler: { action in
                    completion(true)
            })
        )
        
        controller.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { action in
                    completion(false)
            })
        )
        
        present(controller, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        initializeHeader()
    }
    
    private func initializeHeader() {
        
        let headerHeight: CGFloat = 300
        
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: headerHeight))
        tableView.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let heightConstraint = headerView.heightAnchor.constraint(equalToConstant: headerHeight)
        heightConstraint.priority = UILayoutPriorityRequired - 1

        NSLayoutConstraint.activate([
            heightConstraint,
            headerView.heightAnchor.constraint(greaterThanOrEqualToConstant: headerHeight),
            headerView.topAnchor.constraint(lessThanOrEqualTo: topLayoutGuide.bottomAnchor),
            headerView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: headerHeight),
            headerView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: tableView.widthAnchor)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
        loadDocument()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        resignTextFieldIfNeeded()
        super.setEditing(editing, animated: animated)
        tableView.beginUpdates()
        updateModelState()
        tableView.setEditing(editing, animated: animated)
        tableView.endUpdates()
        updateButtonState()
        updateTableCells()
    }
    
    private func resignTextFieldIfNeeded() {
        let cells = tableView.visibleCells
        for cell in cells {
            if let cell = cell as? BasicFragmentCell {
                cell.contentTextField.resignFirstResponder()
            }
        }
    }
    
    private func updateModelState() {
        guard let model = model else {
            return
        }

        model.includeEmptySections = isEditing
    }
    
    private func updateTableCells() {
    
        guard let indexPaths = tableView.indexPathsForVisibleRows else {
            return
        }
        
        for indexPath in indexPaths {
            updateTableCell(at: indexPath)
        }
    }
    
    private func updateTableCell(at indexPath: IndexPath) {
        guard let model = model else {
            return
        }
        guard let cell = tableView.cellForRow(at: indexPath) as? BasicFragmentCell else {
            return
        }
        let type = model.typeForSection(at: indexPath.section)
        print("Configuring cell at \(indexPath) as \(type)")
        cell.configure(type: type, isEditing: self.isEditing)
    }
    
    //
    //  Disable all buttons except for edit/done nav bar button when editing.
    //
    private func updateButtonState() {
        guard let buttonItems = navigationItem.rightBarButtonItems else {
            return
        }
        
        buttonItems.filter({ $0 != editButtonItem }).forEach({ $0.isEnabled = !isEditing })
    }
    
    // MARK: Document
    
    private func clearDocument() {
        model?.clear()
    }
    
    private func loadDocument() {
        do {
            self.document = try coreData.mainContext.documents(withIdentifier: documentIdentifier).first
            
            guard let document = self.document else {
                return
            }
            
            if let imageData = document.thumbnailImageData {
                let image = UIImage(data: imageData as Data, scale: UIScreen.main.scale)
                documentView.image = image
            }
            else {
                documentView.image = nil
            }
            
            documentView.document = document

            model = DocumentViewModel(
                document: document,
                coreData: coreData
            )
            model?.delegate = self
            tableView.reloadData()

            scanDocumentIfNeeded()
        }
        catch {
            print("Cannot fetch document: \(error)")
        }
    }
    
    private func scanDocumentIfNeeded() {
        guard let document = document else {
            return
        }
        
        if document.didCompleteScan {
            return
        }
        
        clearDocument()
        scanDocument()
    }
    
    private func saveDocument() {
        model?.save()
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
            updateViewState(scanning: true)
            
        case .completed:
            print("completed")
            updateViewState(scanning: false)
            model?.fetch()
        }
    }
    
    private func updateViewState(scanning: Bool) {
        scanButtonItem.isEnabled = !scanning
        actionsButtonItem.isEnabled = !scanning
        activityOverlayView.isHidden = !scanning

        if scanning {
            activityIndicatorView.startAnimating()
        }
        else {
            activityIndicatorView.stopAnimating()
        }
    }
    
    // MARK: Table view
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return model?.numberOfSections ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfItems = model?.numberOfRowsInSection(section) ?? 0
        
        if isEditing {
            return numberOfItems + 1
        }
        else {
            return numberOfItems
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model?.titleForSection(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let model = model else {
            return self.tableView(tableView, cellForBlankTextFragmentOfType: .unknown, at: indexPath)
        }
        
        if isEditing && (indexPath.row == model.numberOfRowsInSection(indexPath.section)) {
            let type = model.typeForSection(at: indexPath.section)
            return self.tableView(tableView, cellForBlankTextFragmentOfType: type, at: indexPath)
        }
        
        let fragment = model.fragment(at: indexPath)
        
        switch fragment.type {
            
        default:
            return self.tableView(tableView, cellForTextFragment:fragment, at: indexPath)
        }
    }
    
    private func tableView(_ tableView: UITableView, cellForBlankTextFragmentOfType type: FragmentType, at indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView(tableView, cellForFragmentType: type, at: indexPath)
        return cell
    }
    
    private func tableView(_ tableView: UITableView, cellForTextFragment fragment: Fragment, at indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView(tableView, cellForFragmentType: fragment.type, at: indexPath)
        cell.contentTextField.text = fragment.value
        return cell
    }
    
    private func tableView(_ tableView: UITableView, cellForFragmentType type: FragmentType, at indexPath: IndexPath) -> BasicFragmentCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellIdentifier, for: indexPath) as! BasicFragmentCell
        cell.delegate = self
        cell.configure(type: type, isEditing: isEditing)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard let model = model else {
            return .none
        }
        
        if isEditing {
            if indexPath.row == model.numberOfRowsInSection(indexPath.section) {
                return .insert
            }
            else {
                return .delete
            }
        }
        else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var output = [UITableViewRowAction]()
        
        output.append(
            UITableViewRowAction(
                style: .destructive,
                title: "Delete",
                handler: { (action, indexPath) in
                    self.delete(at: indexPath)
            })
        )
        
        if output.count == 0 {
            return nil
        }
        
        return output
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            
        case .none:
            break
            
        case .delete:
            delete(at: indexPath)
            
        case .insert:
            insert(at: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let model = model, isEditing else {
            return false
        }
        if indexPath.row == model.numberOfRowsInSection(indexPath.section) {
            return false
        }
        else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        guard let model = model else {
            return proposedDestinationIndexPath
        }
        
        return model.targetIndexPathForMove(from: sourceIndexPath, to: proposedDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let model = model else {
            return
        }
        let delegate = model.delegate
        model.delegate = nil
        model.move(from: sourceIndexPath, to: destinationIndexPath)
        model.delegate = delegate
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        
        headerView.backgroundView?.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
    }
    
    // MARK: Cell delegate
    
    func textCell(cell: BasicFragmentCell, textDidChange text: String?) {

        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        guard let model = model else {
            return
        }
        
        if isEditing && indexPath.row == model.numberOfRowsInSection(indexPath.section) {
            insert(value: text, at: indexPath)
            cell.contentTextField.text = nil
        }
        else {
            if text?.isEmpty ?? true {
                delete(at: indexPath)
            }
            else {
                update(value: text, at: indexPath)
            }
        }
    }

    // MARK: Data
    
    private func insert(at indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? BasicFragmentCell, let text = cell.contentTextField.text else {
            return
        }
        cell.contentTextField.text = nil
        insert(value: text, at: indexPath)
    }
    
    private func insert(value: String?, at indexPath: IndexPath) {
        guard let model = model, let value = value else {
            return
        }
        model.insert(value: value, at: indexPath)
    }
    
    private func update(value: String?, at indexPath: IndexPath) {
        guard let model = model else {
            return
        }
        model.update(value: value, at: indexPath)
    }
    
    private func delete(at indexPath: IndexPath) {
        guard let model = model else {
            return
        }
        model.delete(at: indexPath)
    }
}

extension DocumentViewController: DocumentViewModelDelegate {
    func documentModel(model: DocumentViewModel, didUpdateWithChanges changes: DocumentViewModel.Changes) {
        tableView.applyChanges(changes)
    }
}
