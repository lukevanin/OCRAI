//
//  ShareAction.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct ShareAction: Action {
    let title = "Share"
    let style = ActionStyle.normal
    let items: [Any]
    func execute(viewController: UIViewController?) {
        // FIXME: Present modally on iPhone. Present as popover on iPad.
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        viewController?.present(controller, animated: true, completion: nil)
    }
}
