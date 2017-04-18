//
//  EditFieldViewController.swift
//  CardScanner
//
//  Created by Luke Van In on 2017/03/27.
//  Copyright © 2017 Luke Van In. All rights reserved.
//

import UIKit

private let pickerIndexPath = IndexPath(row: 2, section: 0)

extension EditFieldViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return FieldType.all.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(describing: FieldType.all[row])
    }
}

extension EditFieldViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateTypeLabel()
    }
}

extension EditFieldViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

class EditFieldViewController: UITableViewController {
    
    var field: Field!
    
    private var isTypePickerVisible = false
    
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var typePickerView: UIPickerView!
    
    @IBAction func onTypeDropdownAction(_ sender: UIButton) {
        valueTextField.resignFirstResponder()
        setTypePickerVisible(!isTypePickerVisible, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTypePickerVisible(false, animated: false)
        updateView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        commitChanges()
    }
    
    private func commitChanges() {
        let row = typePickerView.selectedRow(inComponent: 0)
        field.type = FieldType.all[row]
        field.value = valueTextField.text
        coreData.saveNow()
    }
    
    private func setTypePickerVisible(_ visible: Bool, animated: Bool) {
        tableView.beginUpdates()
        isTypePickerVisible = visible
        tableView.endUpdates()
    }
    
    private func updateView() {
        valueTextField.text = field.value
        
        let row = FieldType.all.index(of: field.type) ?? 0
        typePickerView.selectRow(row, inComponent: 0, animated: false)
        
        updateTypeLabel()
    }
    
    fileprivate func updateTypeLabel() {
        let row = typePickerView.selectedRow(inComponent: 0)
        let fieldName = String(describing: FieldType.all[row])
        typeLabel.text = fieldName
        valueTextField.placeholder = fieldName
    }
    
    // MARK: Table view
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == pickerIndexPath, !isTypePickerVisible {
            return 0
        }
        else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}
