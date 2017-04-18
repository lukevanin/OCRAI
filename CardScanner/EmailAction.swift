//
//  EmailAction.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import MessageUI

private class EmailViewController: MFMailComposeViewController {
    var strongMailComposeDelegate: MFMailComposeViewControllerDelegate? {
        didSet {
            mailComposeDelegate = strongMailComposeDelegate
        }
    }
}

private class EmailActionDelegate: NSObject, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        assert(Thread.isMainThread)
        if let controller = controller as? EmailViewController {
            controller.strongMailComposeDelegate = nil
        }
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

struct EmailAction: Action {
    let title = "Email"
    let style = ActionStyle.normal
    let emailAddress: String
    
    init(emailAddress: String) {
        self.emailAddress = emailAddress
    }
    
    static var isAvailable: Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func execute(viewController: UIViewController?) {
        let controller = EmailViewController()
        controller.setToRecipients([emailAddress])
        controller.strongMailComposeDelegate = EmailActionDelegate()
        viewController?.present(controller, animated: true, completion: nil)
    }
}
