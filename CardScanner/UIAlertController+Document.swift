//
//  UIAlertController+Document.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/12.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit
import MessageUI
import Contacts

class DocumentMailComposerDelegate: NSObject, MFMailComposeViewControllerDelegate {
    
    private var viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {

    func presentActionsAlertForDocument(document: Document) {
        
        let controller = UIAlertController(
            title: document.title,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        // Fragment actions
        for fragment in document.allFields {
            switch (fragment.type, fragment.value) {
                
            case (.phoneNumber, let .some(value)):
                if let action = makeActionForPhoneNumber(value) {
                    controller.addAction(action)
                }
                
            case (.email, let .some(value)):
                if let action = makeActionForEmail(value) {
                    controller.addAction(action)
                }
                
            case (.url, let .some(value)):
                if let action = makeActionForURL(value) {
                    controller.addAction(action)
                }
                
            default:
                break
            }
        }
        
        // Share actions
        if let action = makeShareAction(for: document) {
            controller.addAction(action)
        }
        
        // Dismiss action
        controller.addAction(makeDismissAction())
        
        self.present(controller, animated: true, completion: nil)
    }
    
    private func makeActionForPhoneNumber(_ value: String) -> UIAlertAction? {
        guard let url = URL(string: value) else {
            return nil
        }
        return UIAlertAction(
            title: "Call \(value)",
            style: .default,
            handler: { (action) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        })
    }
    
    private func makeActionForEmail(_ value: String) -> UIAlertAction? {
        guard let components = URLComponents(string: value), MFMailComposeViewController.canSendMail() else {
            return nil
        }
        let emailAddress = components.path
        return UIAlertAction(
            title: "Email \(emailAddress)",
            style: .default,
            handler: { (action) in
                let controller = MFMailComposeViewController()
                controller.setToRecipients([emailAddress])
                self.present(controller, animated: true, completion: nil)
        })
    }
    
    private func makeActionForURL(_ value: String) -> UIAlertAction? {
        guard let url = URL(string: value) else {
            return nil
        }
        
        return UIAlertAction(
            title: "\(value)",
            style: .default,
            handler: { (action) in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
        })
    }
    
    private func makeShareAction(for document: Document) -> UIAlertAction? {
        let contact = document.contact
        
        guard
            let filename = CNContactFormatter.string(from: contact, style: .fullName),
            let data = try? CNContactVCardSerialization.data(with: [contact]),
            let directory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        else {
            return nil
        }
        
        return UIAlertAction(
            title: "Share Contact",
            style: .default,
            handler: { (action) in
                let file = directory.appendingPathComponent(filename).appendingPathExtension("vcf")
                try! data.write(to: file, options: [.atomic])
                let controller = UIActivityViewController(
                    activityItems: [file],
                    applicationActivities: nil
                )
                self.present(controller, animated: true, completion: nil)
        })
    }

    private func makeDismissAction() -> UIAlertAction {
        return UIAlertAction(
            title: "Dismiss",
            style: .cancel,
            handler: { (action) in
                
        })
    }
}
