//
//  InputPicker.swift
//  subito
//
//  Created by Brandon Guerra Espinoza  on 12/02/25.
//
import SwiftUI

struct PickerField: UIViewRepresentable {
    @Binding var selectionIndex: Date?

    init<S>(_ title: S, selectionIndex: Binding<Date?>) where S: StringProtocol {
        self.placeholder = String(title)
        self._selectionIndex = selectionIndex

        textField = DatePickerYearMonth(selectedDate: selectionIndex)
    }

    func makeUIView(context: UIViewRepresentableContext<PickerField>) -> UITextField {
        textField.placeholder = placeholder
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<PickerField>) {
        if selectionIndex != nil {
            let date = selectionIndex!
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/YYYY"
            uiView.text = formatter.string(from: date)
        }
    }

    private var placeholder: String
    private let textField: DatePickerYearMonth
}

class DatePickerYearMonth: UITextField {
    @Binding var selectedDate: Date?
    
    init(selectedDate: Binding<Date?>){
        self._selectedDate = selectedDate
    
        super.init(frame: .zero)
        self.inputView = pickerView
        self.inputAccessoryView = toolbar
        self.tintColor = .label
    }
    
    required init?(coder: NSCoder) {
        fatalError("Has no implemented")
    }
    
    private lazy var pickerView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .yearAndMonth
        datePicker.preferredDatePickerStyle = .wheels
        
        return datePicker
    }()
    
    private lazy var toolbar: UIToolbar = {
            let toolbar = UIToolbar()

            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

            let doneButton = UIBarButtonItem(
                title: "Hecho",
                style: .done,
                target: self,
                action: #selector(donePressed)
            )

            toolbar.setItems([flexibleSpace, doneButton], animated: false)
            toolbar.sizeToFit()
            return toolbar
        }()

        // MARK: - Private methods
    @objc private func donePressed() {
        self.selectedDate = self.pickerView.date
        self.endEditing(true)
    }
}

extension String {
    func applyPattern(pattern: String = "#### #### #### ####", replacmentCharacter: Character = "#") -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: self)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
