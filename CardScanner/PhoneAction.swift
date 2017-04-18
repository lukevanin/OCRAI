//
//  PhoneAction.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/17.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import Foundation

struct PhoneAction: Action {
    
    let style = ActionStyle.normal
    var title: String {
        return "Call \(phoneNumber)"
    }
    
    let phoneNumber: String
    
    private var url: URL? {
        return URL(string: "tel:\(phoneNumber)")
    }
    
    var canCallPhoneNumber: Bool {
        guard let url = self.url else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
    
    func execute(viewController: UIViewController?) {
        guard let url = self.url else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
