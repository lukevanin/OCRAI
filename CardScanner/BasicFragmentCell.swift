//
//  BasicFragmentCell.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class BasicFragmentCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var contentLabel: UILabel!
    
    func configure(field: Field) {
        contentLabel.text = field.value
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentLabel.text = nil
    }
}
