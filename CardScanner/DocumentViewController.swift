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

private let headerCellIdentifier = "HeaderCell"
private let placeholderCellIdentifier = "PlaceholderCell"
private let basicCellIdentifier = "BasicCell"
private let postalAddressCellIdentifier = "PostalAddressCell"

extension DocumentViewController: DocumentModelDelegate {
    func documentModel(model: DocumentModel, didUpdateWithChanges changes: DocumentModel.Changes) {
        tableView.applyChanges(changes)
    }
}

extension DocumentViewController: ScannerObserver {
    func scanner(service: ScannerService, didChangeState state: ScannerService.State) {
        DispatchQueue.main.async {
            assert(Thread.isMainThread)
            self.handleScannerState(state)
        }
    }
}

extension DocumentViewController: FieldInputDelegate {
    func fieldInput(cell: BasicFragmentCell, valueChanged value: String?) {
        guard
            let indexPath = tableView.indexPath(for: cell),
            let field = model.fragment(at: indexPath) as? Field
        else {
            return
        }
        field.value = value
        model.save()
    }
}

extension DocumentViewController: AddressCellDelegate {
    func addressCellDidChangeAddress(cell: AddressCell) {
        guard
            let indexPath = tableView.indexPath(for: cell),
            let address = model.fragment(at: indexPath) as? PostalAddress
        else {
            return
        }
        address.street = cell.streetTextField.text
        address.city = cell.cityTextField.text
        address.postalCode = cell.postalCodeTextField.text
        address.country = cell.countryTextField.text
        model.save()
    }
}

extension DocumentViewController: PlaceholderCellDelegate {
    func placeholderCellSelected(cell: PlaceholderCell) {
        guard
            let indexPath = tableView.indexPath(for: cell)
        else {
            return
        }
        let _ = model.insert(in: indexPath.section)
        // FIXME: Focus inserted text field.
    }
}

class DocumentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var document: Document!
    var coreData: CoreDataStack!
    var scanner: ScannerService?
    
    private var keyboardController: KeyboardController!
    
    fileprivate var model: DocumentModel!

    @IBOutlet weak var addButtonItem: UIBarButtonItem!
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
            title: "Scan Image",
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
        navigationItem.rightBarButtonItem = editButtonItem
        configureTableView()
        initializeKeyboard()
        initializeHeader()
    }
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
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
    
    private func initializeKeyboard() {
        let toolbarInset = navigationController?.toolbar?.frame.height
        keyboardController = KeyboardController(scrollView: tableView, defaultInset: toolbarInset)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: false)
        scanner?.addObserver(self)
        updateScannerState()
        loadDocument()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scanner?.removeObserver(self)
    }
    
    // MARK: Editing

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        
        // Change separator color depending on edit state.
        let editingSeparatorColor = UIColor(white: 0.9, alpha: 1.0)
        let defaultSeparatorColor = UIColor(white: 0.8, alpha: 1.0)
        tableView.separatorColor = editing ? editingSeparatorColor : defaultSeparatorColor

        // Update placeholders ("Add X" buttons).
        var indexPaths = [IndexPath]()
        for s in 0 ..< model.numberOfSections {
            let r = model.numberOfRowsInSection(s)
            let i = IndexPath(row: r, section: s)
            indexPaths.append(i)
        }

        tableView.beginUpdates()
        if isEditing {
            tableView.insertRows(at: indexPaths, with: .middle)
        }
        else {
            tableView.deleteRows(at: indexPaths, with: .middle)
        }
        tableView.endUpdates()
        
        // Clear out blank data.
        if !editing {
            model.cleanup()
        }
    }
    

    // MARK: Document
    
    private func clearDocument() {
        model?.clear()
    }
    
    private func loadDocument() {
        if let imageData = document.thumbnailImageData {
            let image = UIImage(data: imageData as Data, scale: UIScreen.main.scale)
            documentView.image = image
        }
        else {
            documentView.image = nil
        }
        
        documentView.document = document

        model = DocumentModel(
            document: document,
            coreData: coreData
        )
        model?.delegate = self
        tableView.reloadData()

        scanDocumentIfNeeded()
    }
    
    private func scanDocumentIfNeeded() {
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
        scanner?.scan()
    }
    
    private func updateScannerState() {
        guard let scanner = self.scanner else {
            return
        }
        handleScannerState(scanner.state)
    }
    
    fileprivate func handleScannerState(_ state: ScannerService.State) {
        switch state {
            
        case .active:
            print("active")
            updateViewState(scanning: true)
            
        case .completed:
            print("completed")
            model?.fetch()
            
        case .idle:
            print("idle")
            updateViewState(scanning: false)
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
        let numberOfRows = model?.numberOfRowsInSection(section) ?? 0
        let totalRows = numberOfRows + (isEditing ? 1 : 0)
        return totalRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row >= model.numberOfRowsInSection(indexPath.section) {
            // Place-holder
            let title = model.titleForSection(at: indexPath.section)
            return self.tableView(tableView, cellForPlaceholder: title, at: indexPath)
        }
        else {
            //
        
            let fragment = model.fragment(at: indexPath)
            
            if let field = fragment as? Field {
                return self.tableView(tableView, cellForField: field, at: indexPath)
            }
            else if let address = fragment as? PostalAddress {
                return self.tableView(tableView, cellForPostalAddress: address, at: indexPath)
            }
            else {
                fatalError("unsupported model \(fragment)")
            }
        }
    }
    
    private func tableView(_ tableView: UITableView, cellForField field: Field, at indexPath: IndexPath) -> BasicFragmentCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellIdentifier, for: indexPath) as! BasicFragmentCell
        cell.configure(field: field)
        cell.delegate = self
        cell.accessoryType = .disclosureIndicator
        cell.editingAccessoryType = .none
        return cell
    }
    
    private func tableView(_ tableView: UITableView, cellForPostalAddress address: PostalAddress, at indexPath: IndexPath) -> AddressCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: postalAddressCellIdentifier, for: indexPath) as! AddressCell
        cell.configure(model: address)
        cell.delegate = self;
        cell.accessoryType = .disclosureIndicator
        cell.editingAccessoryType = .none
        return cell
    }
    
    private func tableView(_ tableView: UITableView, cellForPlaceholder title: String, at indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: placeholderCellIdentifier, for: indexPath) as! PlaceholderCell
        cell.titleLabel.text = "Add \(title)"
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row >= model.numberOfRowsInSection(indexPath.section) {
            let _ = model.insert(in: indexPath.section)
            return
        }
        
        guard let actionable = model.fragment(at: indexPath) as? Actionable else {
            return
        }
        
        let controller = actionable.makeAlert(viewController: self)
        present(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row >= model.numberOfRowsInSection(indexPath.section) {
            return .insert
        }
        else {
            return .delete
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
            
        case .delete:
            delete(at: indexPath)
            
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.titleForSection(at: section)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footerView = view as? UITableViewHeaderFooterView else {
            return
        }
        
        footerView.backgroundView?.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }
        
        headerView.backgroundView?.backgroundColor = UIColor.white // UIColor(white: 0.95, alpha: 1.0)
        
        if let label = headerView.textLabel {
            let font = UIFont(name: "Helvetica-Bold", size: 13)
            label.textColor = UIColor(white: 0.8, alpha: 1.0)
            label.font = font
        }
    }
    
    // MARK: Data
    
    private func delete(at indexPath: IndexPath) {
        model.delete(at: [indexPath])
    }
}
