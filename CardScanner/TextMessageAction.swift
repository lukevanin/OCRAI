//
//  TextMessageAction.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import MessageUI

private class MessageViewController: MFMessageComposeViewController {
    var strongMessageComposeDelegate: MFMessageComposeViewControllerDelegate? {
        didSet {
            messageComposeDelegate = strongMessageComposeDelegate
        }
    }
}

private class MessageActionDelegate: NSObject, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        assert(Thread.isMainThread)
        if let controller = controller as? MessageViewController {
            controller.strongMessageComposeDelegate = nil
        }
        controller.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

struct TextMessageAction: Action {
    static var isAvailable: Bool {
        return MFMessageComposeViewController.canSendText()
    }
    var title: String {
        return "Message \(phoneNumber)"
    }
    let style = ActionStyle.normal
    let phoneNumber: String
    func execute(viewController: UIViewController?) {
        let controller = MessageViewController()
        controller.recipients = [phoneNumber]
        controller.strongMessageComposeDelegate = MessageActionDelegate()
        viewController?.present(controller, animated: true, completion: nil)
    }
}
