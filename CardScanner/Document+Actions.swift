//
//  Document+Actions.swift
//  CardScanner
//
//  Created by Anonymous on 2017/03/11.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import Contacts
import MessageUI

class DocumentMailComposerDelegate: NSObject, MFMailComposeViewControllerDelegate {
    
    private var viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension Document {
    
    func presentActions(from viewController: UIViewController) {
        
        let controller = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        // Fragment actions
        for fragment in allFragments {
            switch (fragment.type, fragment.value) {
                
            case (.phoneNumber, let .some(value)):
                if let url = URL(string: value) {
                    controller.addAction(
                        UIAlertAction(
                            title: "Call \(value)",
                            style: .default,
                            handler: { (action) in
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        })
                    )
                }
                
            case (.email, let .some(value)):
                if let components = URLComponents(string: value), MFMailComposeViewController.canSendMail() {
                    let emailAddress = components.path
                    controller.addAction(
                        UIAlertAction(
                            title: "Email \(emailAddress)",
                            style: .default,
                            handler: { (action) in
                                let controller = MFMailComposeViewController()
                                controller.setToRecipients([emailAddress])
                                viewController.present(controller, animated: true, completion: nil)
                        })
                    )
                }
                
            case (.url, let .some(value)):
                if let url = URL(string: value) {
                    controller.addAction(
                        UIAlertAction(
                            title: "\(value)",
                            style: .default,
                            handler: { (action) in
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        })
                    )
                }
                
            default:
                break
            }
        }
        
        // Share actions
        if
            let filename = CNContactFormatter.string(from: contact, style: .fullName),
            let data = try? CNContactVCardSerialization.data(with: [contact]),
            let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        {
            controller.addAction(
                UIAlertAction(
                    title: "Share Contact",
                    style: .default,
                    handler: { (action) in
                        let file = directory.appendingPathComponent(filename).appendingPathExtension("vcf")
                        try! data.write(to: file, options: [.atomic])
                        let controller = UIActivityViewController(
                            activityItems: [file],
                            applicationActivities: nil
                        )
                        viewController.present(controller, animated: true, completion: nil)
                })
            )
        }
        
        // Dismiss action
        controller.addAction(
            UIAlertAction(
                title: "Dismiss",
                style: .cancel,
                handler: { (action) in
                    
            })
        )
        
        viewController.present(controller, animated: true, completion: nil)
    }
}
