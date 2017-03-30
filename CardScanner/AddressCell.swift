//
//  AddressCell.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/28.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import MapKit

class AddressCell: UITableViewCell {
    
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var postalCodeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        streetLabel.text = nil
        cityLabel.text = nil
        postalCodeLabel.text = nil
        countryLabel.text = nil
        configure(location: nil)
    }

    func configure(model: PostalAddress) {
        configure(label: streetLabel, value: model.street, defaultValue: "Street")
        configure(label: cityLabel, value: model.city, defaultValue: "City")
        configure(label: postalCodeLabel, value: model.postalCode, defaultValue: "Postal Code")
        configure(label: countryLabel, value: model.country, defaultValue: "Country")
        configure(location: model.location)
    }
    
    private func configure(label: UILabel, value: String?, defaultValue: String) {
        if let value = value, !value.isEmpty {
            label.text = value
            label.isHidden = false
        }
        else {
            label.text = defaultValue
            label.isHidden = true
        }
    }
    
    private func configure(location: CLLocationCoordinate2D?) {
        let span: MKCoordinateSpan
        let center: CLLocationCoordinate2D
        
        if let location = location {
            center = location
            span = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        }
        else {
            center = mapView.centerCoordinate
            span = MKCoordinateSpan(latitudeDelta: 180, longitudeDelta: 360)
        }

        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)
    }
}
