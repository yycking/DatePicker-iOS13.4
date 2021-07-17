//
//  DatePicker.swift
//  DatePicker+iOS13.4
//
//  Created by YungCheng Yeh on 2021/7/17.
//

import UIKit

@dynamicMemberLookup
class DatePicker: UIView {
    private var _datePicker = UIDatePicker()
    private var textField = UITextField()
    private var button = UIButton()
    private var tapOutside: UITapGestureRecognizer?
    
    private var currentStyleView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let view = currentStyleView {
                view.frame = self.bounds
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.addSubview(view)
            }
        }
    }
    
    enum Style {
        case `default`
        case button
        case textField
    }
    var style: Style = .default {
        didSet {
            if #available(iOS 13.4, *) {
                switch style {
                case .default:
                    currentStyleView = _datePicker
                    _datePicker.preferredDatePickerStyle = .compact
                case .button:
                    currentStyleView = button
                    _datePicker.preferredDatePickerStyle = .wheels
                case .textField:
                    currentStyleView = textField
                    _datePicker.preferredDatePickerStyle = .wheels
                }
            } else {
                switch style {
                case .default,
                     .button:
                    currentStyleView = button
                case .textField:
                    currentStyleView = textField
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.4, *) {
            style = .default
        } else {
            style = .button
        }
        
        setupTextField()
        setupButton()
        
        _datePicker.addTarget(self, action: #selector(changed), for: .valueChanged)
        
        tapOutside = UITapGestureRecognizer(target: self, action: #selector(tap(outside:)))
        tapOutside?.cancelsTouchesInView = false
        
        updatePreview()
    }
    
    private func updatePreview() {
        let formatter = DateFormatter()
        formatter.calendar = _datePicker.calendar
        formatter.locale = _datePicker.locale
        formatter.timeZone = _datePicker.timeZone
        switch _datePicker.datePickerMode {
        case .time:
            formatter.dateStyle = .none
            formatter.timeStyle = .short
        case .date:
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
        case .dateAndTime:
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
        default:
            break
        }
        let date = _datePicker.date
        let text = formatter.string(from: date)
        textField.text = text
        button.setTitle(text, for: .normal)
    }
    
    private var parentController: UIViewController? {
        return sequence(first: self){$0.next}
            .first {$0 is UIViewController} as? UIViewController
    }
    
    @objc func changed(_: UIDatePicker) {
        updatePreview()
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<UIDatePicker, T>) -> T {
        return _datePicker[keyPath: keyPath]
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<UIDatePicker, T>) -> T {
        get {
            return _datePicker[keyPath: keyPath]
        }
        set(newValue) {
            _datePicker[keyPath: keyPath] = newValue
            updatePreview()
        }
    }
}

extension DatePicker {
    func setupButton() {
        button.setTitleColor(_datePicker.tintColor, for: .normal)
        button.addTarget(self, action: #selector(touch), for: .touchUpInside)
    }
    
    @objc func touch(_ sender: UIButton) {
        let alertController = UIViewController()
        let alertView = alertController.view!
        if UIDevice.current.userInterfaceIdiom == .pad {
            _datePicker.frame = alertView.bounds
            _datePicker.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        } else {
            if #available(iOS 13.0, *) {
                _datePicker.backgroundColor = .systemBackground
            } else {
                _datePicker.backgroundColor = .white
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(tap(outside:)))
            alertView.addGestureRecognizer(tap)
            _datePicker.center = alertView.center
            _datePicker.autoresizingMask = []
        }
        alertView.addSubview(_datePicker)
        
        alertController.modalPresentationStyle = .popover
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        parentController?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func tap(outside: Any?) {
        switch currentStyleView {
        case button:
            parentController?.dismiss(animated: true, completion: nil)
        case textField:
            self.endEditing(true)
        default:
            break
        }
    }
}

extension DatePicker: UITextFieldDelegate {
    func setupTextField() {
        textField.inputView = _datePicker
        textField.tintColor = .clear
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let tapOutside = tapOutside else { return }
        parentController?.view.addGestureRecognizer(tapOutside)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let tapOutside = tapOutside else { return }
        parentController?.view.removeGestureRecognizer(tapOutside)
    }
}
