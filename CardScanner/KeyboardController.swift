//
//  KeyboardController.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/04/23.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

class KeyboardController: NSObject {
    
    weak var scrollView: UIScrollView?
    
    private var currentInset: CGFloat = 0 {
        didSet {
            guard let scrollView = scrollView else {
                return
            }
            
            let oldInset = scrollView.contentInset
            var newInset = oldInset
            newInset.bottom = max(currentInset, defaultInset)
            
            guard newInset != oldInset else {
                return
            }
            
            scrollView.contentInset = newInset
            scrollView.scrollIndicatorInsets = newInset
        }
    }
    
    private var defaultInset: CGFloat = 0
    
    required init(scrollView: UIScrollView? = nil, defaultInset: CGFloat? = nil) {
        super.init()
        self.scrollView = scrollView
        self.defaultInset = defaultInset ?? scrollView?.contentInset.bottom ?? 0
        addNotificationObservers()
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    private func addNotificationObservers() {
        let notifications = NotificationCenter.default
        notifications.addObserver(self, selector: #selector(handleUIKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notifications.addObserver(self, selector: #selector(handleUIKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        notifications.addObserver(self, selector: #selector(handleUIKeyboardNotification), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    private func removeNotificationObservers() {
        let notifications = NotificationCenter.default
        notifications.removeObserver(self)
    }
    
    func handleUIKeyboardNotification(notification: Notification) {
        assert(Thread.isMainThread)
        
        guard
            let userInfo = notification.userInfo,
            let endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber,
            let curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber,
            let curve = UIViewAnimationCurve(rawValue: curveValue.intValue),
            let window = scrollView?.window
        else {
            return
        }

        let endFrame = endFrameValue.cgRectValue
        let screen = UIScreen.main
        let finalFrame = window.convert(endFrame, from: screen.coordinateSpace)
        let inset = screen.bounds.size.height - finalFrame.minY
        let duration = durationValue.doubleValue
        let curveOption = curve.animationOption
        
        if currentInset == inset {
            return
        }
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.beginFromCurrentState, curveOption],
            animations: { [weak self] in
                self?.currentInset = inset
        })
    }
}
