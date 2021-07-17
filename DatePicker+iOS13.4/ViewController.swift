//
//  ViewController.swift
//  DatePicker+iOS13.4
//
//  Created by YungCheng Yeh on 2021/7/17.
//

import UIKit

class ViewController: UITableViewController {
    @IBOutlet weak var defaultDatePicker: DatePicker!
    @IBOutlet weak var buttonDatePicker: DatePicker!
    @IBOutlet weak var textFieldDatePicker: DatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        buttonDatePicker.style = .button
        textFieldDatePicker.style = .textField
    }


}

