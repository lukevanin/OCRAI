//
//  ShowAddressAction.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import MapKit
import Contacts

struct ShowAddressAction: Action {
    
    let title = "Open in Maps"
    let style = ActionStyle.normal
    
    let address: CNPostalAddress
    let coordinate: CLLocationCoordinate2D?
    
    func execute(viewController: UIViewController?) {
        if let coordinate = coordinate {
            // Coordinate provided.
            // Show the placemark based on the address and coordinate.
            let placemark = MKPlacemark(coordinate: coordinate, postalAddress: address)
            self.showPlacemark(placemark: placemark)
        }
        else {
            // Coordinate is not provided.
            // Lookup the coordinate from the address, if possible, then show the map.
            lookupCoordinate { placemark, error in
                DispatchQueue.main.async {
                    guard let placemark = placemark else {
                        print("Cannot geocode address: \(error)")
                        if let viewController = viewController {
                            self.showError(error: error, viewController: viewController)
                        }
                        return
                    }
                    self.showPlacemark(placemark: placemark)
                }
            }
        }
    }
    
    private func showPlacemark(placemark: MKPlacemark) {
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.openInMaps(launchOptions: nil)
    }
    
    private func lookupCoordinate(completion: @escaping (MKPlacemark?, Error?) -> Void) {
        let addressString = CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
        
        // FIXME: Use shared GL coder queue to de-duplicate requests, and prevent channel flooding.
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            guard let placemark = placemarks?.first else {
                completion(nil, error)
                return
            }
            
            let mapPlacemark = MKPlacemark(placemark: placemark)
            completion(mapPlacemark, nil)
        }
    }
    
    private func showError(error: Error?, viewController: UIViewController) {
        
        let message = error?.localizedDescription ?? "Cannot geocode address into a map location."
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "Dismiss",
                style: .cancel,
                handler: nil
            )
        )
        
        viewController.present(alertController, animated: true, completion: nil)
    }
}
