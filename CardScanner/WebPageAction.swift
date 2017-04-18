//
//  WebPageAction.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation
import SafariServices

struct WebPageAction: Action {
    let title = "Open Web Page"
    let style = ActionStyle.normal
    let url: URL
    func execute(viewController: UIViewController?) {
        let controller = SFSafariViewController(url: url)
        viewController?.present(controller, animated: true, completion: nil)
    }
}
