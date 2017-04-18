//
//  Actionable.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/14.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

enum ActionStyle {
    case normal
    case destructive
}

protocol Action {
    var title: String {
        get
    }
    
    var style: ActionStyle {
        get
    }
    
    func execute(viewController: UIViewController?)
}

protocol Actionable {
    var actions: [Action] {
        get
    }
    
    var actionsTitle: String? {
        get
    }
    
    var actionsDescription: String? {
        get
    }
}

// MARK: UIAlert

extension ActionStyle {
    var alertActionStyle: UIAlertActionStyle {
        switch self {
        case .normal:
            return .default
            
        case .destructive:
            return .destructive
        }
    }
}

extension Action {
    func makeAlertAction(viewController: UIViewController) -> UIAlertAction {
        return UIAlertAction(
            title: self.title,
            style: self.style.alertActionStyle,
            handler: { [weak viewController] (action) in
                self.execute(viewController: viewController)
        })
    }
}

extension Actionable {
    func makeAlert(viewController: UIViewController) -> UIAlertController {

        let controller = UIAlertController(
            title: actionsTitle,
            message: actionsDescription,
            preferredStyle: .actionSheet
        )
        
        // Add actions
        for action in actions {
            let action = action.makeAlertAction(viewController: viewController)
            controller.addAction(action)
        }
        
        // Add default dismiss action
        controller.addAction(
            UIAlertAction(
                title: "Dismiss",
                style: .cancel,
                handler: nil
            )
        )
        
        return controller
    }
}
