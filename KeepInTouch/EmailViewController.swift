//
//  EmailViewController.swift
//  KeepInTouch
//
//  Created by Mitchell Gant on 11/3/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit

class EmailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var toEmail: String?
    var fromAddress = "mgant20151@gmail.com"

    @IBOutlet weak var toTextField: UITextField!
    @IBOutlet weak var subjectTextField: UITextField!
    
    @IBOutlet weak var messageTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = toEmail {
            toTextField.text = email
        }
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMessageBtnPressed(_ sender: Any) {
        let emailTo = toTextField.text!
        let message = messageTextView.text!
        let emailSubject = subjectTextField.text!
        let dataURLString = "api_user=mgant6&api_key=myb1rthmark&to=\(emailTo)&toname=Destination&subject=\(emailSubject)&text=\(message)&from=\(fromAddress)"
        
        let urlString = "https://api.sendgrid.com/api/mail.send.json"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = dataURLString.data(using: .ascii)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else{
                return
            }
            print("everything seems to be working")
            
        }
        
        task.resume()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

}
