//
//  ColorGeneratorViewController.swift
//  ColorGenerator
//
//  Created by Anil Guven on 19/08/2023.
//

import UIKit

class ColorGeneratorViewController: UIViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var hexLabel: UILabel!
    @IBOutlet var textFields: [UITextField]!
    @IBOutlet var sliders: [UISlider]!
    @IBOutlet weak var toolbar: UIToolbar!
    
    // MARK: - Properties
    var currentColor: UIColor {
        let redValue = Double(sliders[0].value) / 255.0
        let greenValue = Double(sliders[1].value) / 255.0
        let blueValue = Double(sliders[2].value) / 255.0
        
        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1)
    }
    
    var hexColorString: String {
        guard let components = currentColor.cgColor.components, components.count >= 3 else {
            return "#000000"
        }
        
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        
        return String(
            format: "#%02lX%02lX%02lX",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
    }
    
    var activeTextField: UITextField? {
        return textFields.filter({ $0.isFirstResponder }).first
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFields.forEach { textField in
            textField.font = .monospacedDigitSystemFont(ofSize: 17, weight: .regular)
            textField.inputAccessoryView = toolbar
        }
        
        hexLabel.font = .monospacedSystemFont(ofSize: 25, weight: .semibold)
        colorView.layer.cornerRadius = 20
    }
    
    // MARK: - Methods
    func formStringValue(from value: Float) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.numberStyle = .decimal
        
        let number = NSNumber(value: value)
        let formattedString = numberFormatter.string(from: number)
        
        if let formattedString {
            return formattedString
        } else {
            return String(value)
        }
    }
    
    // MARK: - Actions
    @IBAction func resetBarButtonTapped() {
        UIViewPropertyAnimator(duration: 0.25, curve: .easeOut) {
            self.colorView.backgroundColor = .black
        }.startAnimation()
        
        // Sets all slider.value to 0 with animation.
        sliders.forEach({ $0.setValue(0, animated: true) })
        
        // Sets all textField.text values to nil.
        textFields.forEach({ $0.text = nil })
        
        hexLabel.text = hexColorString
    }
    
    @IBAction func sliderValueChanged(_ slider: UISlider) {
        let valueString = formStringValue(from: slider.value)
        
        colorView.backgroundColor = currentColor
        hexLabel.text = hexColorString
        textFields[slider.tag].text = valueString
    }
    
    @IBAction func resetColorBarButtonTapped() {
        guard let textField = activeTextField else { return }
        let slider = sliders[textField.tag]
        
        textField.text = nil
        slider.setValue(0, animated: true)
        colorView.backgroundColor = currentColor
    }
    
    @IBAction func doneBarButtonTapped() {
        guard let textField = activeTextField else { return }
        let slider = sliders[textField.tag]
        
        // Take value as Float if the text is not nil, otherwise 0.
        var value = Float(textField.text!) ?? 0.0
        
        // Shifting the range from -inf...+inf to 0...255
        value = max(0, min(255, value))
        
        textField.text = formStringValue(from: value)
        slider.setValue(value, animated: true)
        colorView.backgroundColor = currentColor
        textField.resignFirstResponder()
    }
    
    @IBAction func copyToClipboardButtonTapped() {
        let alert = UIAlertController(title: "Color Copied!", message: "Your color has been copied to your pasteboard.", preferredStyle: .alert)
        
        let doneAction = UIAlertAction(title: "Done", style: .default)
        
        alert.addAction(doneAction)
        
        present(alert, animated: true)
        UIPasteboard.general.string = "Hey, here is my hex color: \(hexColorString)"
    }
}
