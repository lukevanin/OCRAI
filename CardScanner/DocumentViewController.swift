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

private let basicCellIdentifier = "BasicCell"
private let locationCellIdentifier = "LocationCell"
private let imageCellIdentifier = "ImageCell"

class DocumentViewController: UITableViewController {

    var documentIdentifier: String!
    var coreData: CoreDataStack!
    
    private lazy var scanner: ScannerService = {
        let factory = DefaultServiceFactory()
        return ScannerService(
            factory: factory,
            coreData: self.coreData
        )
    }()
    
    private var fragments = [Any]()
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBAction func onScanAction(_ sender: Any) {
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
    
    // MARK: Document
    
    private func clearDocument(completion: @escaping () -> Void) {
        fragments.removeAll()
        
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
            
            if let locations = document?.locations?.allObjects as? [LocationFragment] {
                for location in locations {
                    context.delete(location)
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
            let document = try coreData.mainContext.documents(withIdentifier: documentIdentifier).first
            
            if let imageData = document?.imageData {
                headerImageView.image = UIImage(data: imageData as Data)
            }
            
            if let imageFragments = document?.imageFragments?.allObjects {
                fragments.append(contentsOf: imageFragments)
            }
            
            if let textFragments = document?.textFragments?.allObjects {
                fragments.append(contentsOf: textFragments)
            }
            
            if let locations = document?.locations?.allObjects {
                fragments.append(contentsOf: locations)
            }
            
            tableView.reloadData()
        }
        catch {
            print("Cannot fetch document: \(error)")
        }
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
            activityIndicatorView.startAnimating()
            
        case .completed:
            print("completed")
            activityIndicatorView.stopAnimating()
            loadDocument()
        }
    }
    
    // MARK: Table view
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fragments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = fragments[indexPath.row]
        
        switch item {
            
        case let fragment as TextFragment:
            return self.tableView(tableView, cellForTextFragment:fragment, at: indexPath)
            
        case let fragment as ImageFragment:
            return self.tableView(tableView, cellForImageFragment:fragment, at: indexPath)
            
        case let fragment as LocationFragment:
            return self.tableView(tableView, cellForLocationFragment:fragment, at: indexPath)
            
        default:
            fatalError("Unknown fragment type: \(item)")
        }
    }
    
    private func tableView(_ tableView: UITableView, cellForTextFragment fragment: TextFragment, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: basicCellIdentifier, for: indexPath) as! BasicFragmentCell
        cell.titleLabel.text = fragment.type.description
        cell.contentLabel.text = fragment.value
        return cell
    }
    
    private func tableView(_ tableView: UITableView, cellForImageFragment fragment: ImageFragment, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: imageCellIdentifier, for: indexPath) as! ImageFragmentCell
        return cell
    }
    
    private func tableView(_ tableView: UITableView, cellForLocationFragment fragment: LocationFragment, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: locationCellIdentifier, for: indexPath) as! LocationFragmentCell
        cell.titleLabel.text = "Address"
        cell.contentLabel.text = fragment.address
        
        let coordinate = fragment.coordinate
        let span = MKCoordinateSpan(
            latitudeDelta: 0.1,
            longitudeDelta: 0.1
        )
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        let region = MKCoordinateRegion(
            center: coordinate,
            span: span
        )
        
        cell.mapView.addAnnotation(annotation)
        cell.mapView.setRegion(region, animated: false)
        
        return cell
    }
}
