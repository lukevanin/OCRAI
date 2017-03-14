//
//  DocumentCell.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell {
    @IBOutlet weak var backgroundImageView: UIImageView?
    @IBOutlet weak var placeholderImageView: UIImageView?
    @IBOutlet weak var documentView: DocumentView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        if let layer = documentView?.layer {
//            layer.borderWidth = 1
//            layer.borderColor = UIColor(white: 0.66, alpha: 1.0).cgColor
//        }
        
        if let layer = backgroundImageView?.layer {
            layer.backgroundColor = UIColor.white.cgColor
            layer.masksToBounds = false
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 4
        }
        
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundImageView?.image = nil
        placeholderImageView?.image = nil
        documentView?.document = nil
        titleLabel?.text = nil
        subtitleLabel?.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let backgroundImageView = self.backgroundImageView {
            let layer = backgroundImageView.layer
            layer.shadowPath = UIBezierPath(rect: backgroundImageView.bounds).cgPath
        }
    }
    
    func configure(with document: Document) {
        documentView?.document = document
        
        // FIXME: Instantiate image in background thread
        if let imageData = document.thumbnailImageData, let image = UIImage(data: imageData as Data, scale: UIScreen.main.scale) {
            documentView?.image = image
            documentView?.isHidden = false
            placeholderImageView?.isHidden = true
        }
        else {
            documentView?.image = nil
            documentView?.isHidden = true
            placeholderImageView?.isHidden = false
        }
        
        let titles = document.titles
        
        if titles.count > 0 {
            titleLabel?.text = titles[0]
            
            if titles.count > 1 {
                subtitleLabel?.text = titles[1]
            }
        }
        else {
            titleLabel?.text = "Tap to scan"
        }
    }
}
