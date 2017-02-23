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
    
    weak var delegate: TextCellDelegate?
    
    @IBOutlet weak var contentTextField: UITextField!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentTextField.text = nil
    }
    
    override func willTransition(to state: UITableViewCellStateMask) {
        super.willTransition(to: state)
        
        if state.contains(.showingEditControlMask) {
            contentTextField.isUserInteractionEnabled = true
            contentTextField.layer.cornerRadius = 0 // FIXME: Show radius. Apply margins.
            contentTextField.backgroundColor = UIColor.init(white: 0.95, alpha: 1.0)
        }
        else {
            contentTextField.isUserInteractionEnabled = false
            contentTextField.layer.cornerRadius = 0
            contentTextField.backgroundColor = UIColor.white
            
            if contentTextField.isFirstResponder {
                contentTextField.resignFirstResponder()
            }
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
