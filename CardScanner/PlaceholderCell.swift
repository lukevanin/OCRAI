//
//  PlaceholderCell.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/23.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

protocol PlaceholderCellDelegate: class {
    func placeholderCellSelected(cell: PlaceholderCell)
}

class PlaceholderCell: UITableViewCell {
    weak var delegate: PlaceholderCellDelegate?
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func onSelectionAction(_ sender: UIButton) {
        delegate?.placeholderCellSelected(cell: self)
    }
}
