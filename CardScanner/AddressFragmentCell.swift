//
//  AddressFragmentCell.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/23.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class AddressFragmentCell: UITableViewCell {
    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var postalCodeTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        streetTextField.text = nil
        cityTextField.text = nil
        postalCodeTextField.text = nil
        countryTextField.text = nil
    }
    
    func configure(fragment: AddressFragment) {
        configureTextField(streetTextField, value: fragment.street)
        configureTextField(cityTextField, value: fragment.city)
        configureTextField(postalCodeTextField, value: fragment.postalCode)
        configureTextField(countryTextField, value: fragment.country)
    }
    
    private func configureTextField(_ textField: UITextField, value: String?) {
        textField.text = value
        textField.isHidden = value?.isEmpty ?? true
    }
}
