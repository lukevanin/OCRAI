//
//  BasicFragmentCell.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

protocol FieldInputDelegate: class {
    func fieldInput(cell: BasicFragmentCell, valueChanged value: String?)
}

extension BasicFragmentCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.delegate?.fieldInput(cell: self, valueChanged: value)
    }
}

class BasicFragmentCell: UITableViewCell {
    
    weak var delegate: FieldInputDelegate?
    
    @IBOutlet weak var contentTextField: UITextField!
    
    var value: String? {
        return contentTextField.text
    }
    
    func configure(field: Field) {
        contentTextField.placeholder = String(describing: field.type)
        contentTextField.text = field.value
        contentTextField.keyboardType = field.type.preferredKeyboardType
        enableTextInputIfNeeded(animated: true)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        enableTextInputIfNeeded(animated: animated)
    }
    
    private func enableTextInputIfNeeded(animated: Bool) {
        setInputEnabled(isEditing, animated: animated)
    }
    
    private func setInputEnabled(_ enabled: Bool, animated: Bool) {
        
        if contentTextField.isFirstResponder && !enabled {
            contentTextField.resignFirstResponder()
        }
        
        contentTextField.isUserInteractionEnabled = enabled
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
        contentTextField.placeholder = nil
        contentTextField.text = nil
        setInputEnabled(false, animated: false)
    }
}
