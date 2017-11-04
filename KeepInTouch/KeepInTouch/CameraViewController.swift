//
//  CameraViewController.swift
//  KeepInTouch
//
//  Created by Mitchell Gant on 11/3/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import FirebaseAuth

class CameraViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "KIT"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        checkIfUserIsLoggedIn()
    }

    @objc func handleLogout() {
        present(LoginViewController(), animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            self.present(LoginViewController(), animated: true, completion: nil)
        }
    }
}

extension UIColor {
    convenience init(red: Int = 0, green: Int = 0, blue: Int = 0, opacity: Int = 255) {
        precondition(0...255 ~= red   &&
            0...255 ~= green &&
            0...255 ~= blue  &&
            0...255 ~= opacity, "input range is out of range 0...255")
        self.init(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(opacity)/255)
    }
}
