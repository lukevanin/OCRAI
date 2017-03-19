//
//  BasicFragmentCell.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

protocol TextCellDelegate: class {
    func textCell(cell: BasicFragmentCell, textDidChange text: String?)
}

class BasicFragmentCell: UITableViewCell, UITextFieldDelegate {
    
    var editingEnabled = false {
        didSet {
            setEditable(editingEnabled)
        }
    }
    
    weak var delegate: TextCellDelegate?
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var colorAccentView: UIView!
    @IBOutlet weak var contentTextField: UITextField!
    
    func configure(type: FragmentType, isEditing: Bool) {
        colorView.backgroundColor = isEditing ? UIColor(white: 0.90, alpha: 1.0) : UIColor.clear
        colorAccentView.backgroundColor = type.accentColor //withAlphaComponent(0.95)
        editingEnabled = isEditing
        showsReorderControl = true
        accessoryType = .none
        editingAccessoryType = .none
        contentTextField.placeholder = type.description
}

    override func awakeFromNib() {
        super.awakeFromNib()
        editingEnabled = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentTextField.text = nil
        editingEnabled = false
        colorView.backgroundColor = .clear
        colorAccentView.backgroundColor = .clear
        showsReorderControl = false
        accessoryType = .none
        editingAccessoryType = .none
        contentTextField.placeholder = nil
    }
    
    override func willTransition(to state: UITableViewCellStateMask) {
        super.willTransition(to: state)
        
        if state.contains(.showingEditControlMask) {
            editingEnabled = true
        }
        else {
            editingEnabled = false
        }
    }
    
    func setEditable(_ enable: Bool) {
        contentTextField.isUserInteractionEnabled = enable
        
        if !enable && contentTextField.isFirstResponder {
            contentTextField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textCell(cell: self, textDidChange: textField.text)
    }
}
