//
//  UIImagePickerController+UIAlertController.swift
//  AutoTranslate
//
//  Created by Luke Van In on 2017/02/03.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

typealias ImagePickerAlertCompletion = (UIImage?) -> Void

private var delegates = [ImagePickerDelegate]()

extension UIViewController {
    
    func showImagePicker(animated: Bool, completion: @escaping ImagePickerAlertCompletion) {
        
        let controller = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.addAction(
                UIAlertAction(
                    title: "Camera",
                    style: .default,
                    handler: { (action) in
                        self.showImagePicker(source: .camera, completion: completion)
                })
            )
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            controller.addAction(
                UIAlertAction(
                    title: "Library",
                    style: .default,
                    handler: { (action) in
                        self.showImagePicker(source: .photoLibrary, completion: completion)
                })
            )
        }
        
        controller.addAction(
            UIAlertAction(
                title: "Dismiss",
                style: .cancel,
                handler: { _ in
                    completion(nil)
            })
        )

        present(controller, animated: animated, completion: nil)
    }

    private func showImagePicker(source: UIImagePickerControllerSourceType, completion: @escaping ImagePickerAlertCompletion) {
        
        let delegate = ImagePickerDelegate()
        delegate.completion = completion
        delegates.append(delegate)

        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = delegate
        present(picker, animated: true, completion: nil)
    }
}

class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var completion: ImagePickerAlertCompletion?
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        removeDelegate()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        completion?(image)
        removeDelegate()
    }
    
    private func removeDelegate() {
        if let i = delegates.index(of: self) {
            delegates.remove(at: i)
        }
    }
}
