//
//  CopyTextAction.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/18.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import MobileCoreServices

struct CopyTextAction: Action {
    let title = "Copy"
    let style = ActionStyle.normal
    let text: String
    func execute(viewController: UIViewController?) {
        let pasteboard = UIPasteboard.general
        pasteboard.setValue(text, forPasteboardType: kUTTypeUTF8PlainText as String)
    }
}
