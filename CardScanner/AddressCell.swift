//
//  AddressCell.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/28.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import MapKit

protocol AddressCellDelegate: class {
    func addressCellDidChangeAddress(cell: AddressCell)
}

extension AddressCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.addressCellDidChangeAddress(cell: self)
    }
}

class AddressCell: UITableViewCell {
    
    weak var delegate: AddressCellDelegate?
    
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
        streetTextField.text = nil
        cityTextField.text = nil
        postalCodeTextField.text = nil
        countryTextField.text = nil
        setInputEnabled(false)
        configure(location: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        setInputEnabled(editing)
        mapView.isHidden = editing
    }
    
    private func setInputEnabled(_ enabled: Bool) {
        setInputEnabled(enabled, forTextField: streetTextField)
        setInputEnabled(enabled, forTextField: cityTextField)
        setInputEnabled(enabled, forTextField: postalCodeTextField)
        setInputEnabled(enabled, forTextField: countryTextField)
    }
    
    private func setInputEnabled(_ enabled: Bool, forTextField textField: UITextField) {
        
        if !enabled && textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        
        textField.isUserInteractionEnabled = enabled
        setVisibilityForTextField(textField)
    }

    func configure(model: PostalAddress) {
        configure(textField: streetTextField, value: model.street, defaultValue: "Street")
        configure(textField: cityTextField, value: model.city, defaultValue: "City")
        configure(textField: postalCodeTextField, value: model.postalCode, defaultValue: "Postal Code")
        configure(textField: countryTextField, value: model.country, defaultValue: "Country")
        configure(location: model.location)
    }
    
    private func configure(textField: UITextField, value: String?, defaultValue: String) {
        textField.text = value
        textField.placeholder = defaultValue
        setVisibilityForTextField(textField)
    }
    
    private func setVisibilityForTextField(_ textField: UITextField) {
        
        // FIXME: Row height is not updated when changing table view setEditing.
        
//        let isEmpty = textField.text?.isEmpty ?? true
//        textField.isHidden = isEditing ? false : isEmpty
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
