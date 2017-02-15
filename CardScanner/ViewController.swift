//
//  ViewController.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/02/08.
//  Copyright © 2017 Luke Van In. All rights reserved.
//
//  TODO: 
//
//      1. Deskew image based on detected rectangle.
//      2. Resize image to limits.
//      3. Process detected QR code.
//      4. NSDataDetector: Detect phone numbers, links, and addresses.
//      5. Google vision API: OCR, faces, and logos.
//      6. Google natural language API: Detect names and organizations.
//      7. Create contact edit sheet.
//      8. Save contact to core data.
//      9. Export contact to address book.
//

import UIKit
import Contacts

class ViewController: UIViewController {
    
    private let googleKey = "AIzaSyDTdcgltBmKzyR1n-eG2Vjc7L4vBBbpQ90"
    
    private lazy var scannerService: ScannerService = {
        return ScannerService.mock()
    }()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var photoButton: UIButton!
    
    @IBAction func onPhotoButtonAction(_ sender: Any) {
        showImagePicker(animated: true) { [weak self] (image) in
            if let image = image {
                self?.selectImage(image: image)
            }
        }
    }
    
    private func selectImage(image: UIImage) {
        
        textView.text = nil
        imageView.image = image
        activityIndicator.startAnimating()
        photoButton.isHidden = true
        
        processImage(image: image) {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.photoButton.isHidden = false
            }
        }
    }
    
    private func processImage(image: UIImage, completion: @escaping () -> Void) {
        scannerService.scan(image: image) { document, error in
            DispatchQueue.main.async {
                guard let document = document else {
                    completion()
                    return
                }
                
                print("==========")
                print("Document:")
                print(document)
                print("==========")
                print()
                
                self.textView.text = document.description
                completion()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

