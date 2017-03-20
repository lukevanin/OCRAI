//
//  DocumentCell.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/15.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class DocumentCell: UITableViewCell {
    
    private var document: Document?
    private var scanner: ScannerService? {
        willSet {
            scanner?.removeObserver(self)
        }
        didSet {
            scanner?.addObserver(self)
        }
    }
    
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
        document = nil
        scanner = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let backgroundImageView = self.backgroundImageView {
            let layer = backgroundImageView.layer
            layer.shadowPath = UIBezierPath(rect: backgroundImageView.bounds).cgPath
        }
    }
    
    func configure(with document: Document, scanner: ScannerService?) {
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
        
        self.document = document
        self.scanner = scanner
        updateView()
    }
    
    fileprivate func updateView() {
        
        var title: String?
        var subtitle: String?

        let isScanned = document?.didCompleteScan ?? false
        
        if let scanner = self.scanner, scanner.state != .idle {
            title = "Scanning..."
        }
        else {
            if isScanned {
                if let titles = document?.titles, titles.count > 0 {
                    title = titles[0]
                    
                    if titles.count > 1 {
                        subtitle = titles[1]
                    }
                }
                else {
                    title = "No content"
                }
            }
            else {
                title = "Tap to scan"
            }
        }
        
        titleLabel?.text = title
        subtitleLabel?.text = subtitle
    }
}

extension DocumentCell: ScannerObserver {
    func scanner(service: ScannerService, didChangeState: ScannerService.State) {
        DispatchQueue.main.async {
            assert(Thread.isMainThread)
            self.updateView()
        }
    }
}
