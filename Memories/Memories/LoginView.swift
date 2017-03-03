//
//  LoginView.swift
//  Memories
//
//  Created by Felicity Johnson on 2/9/17.
//  Copyright © 2017 FJ. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginView: UIView, FBSDKLoginButtonDelegate {

    lazy var loginButton: FBSDKLoginButton = {
        return FBSDKLoginButton()
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loginButton.delegate = self
        configLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configLayout() {
        self.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Error logging into FB: \(error)")
        } else if result.isCancelled {
                print("Cancelled")
        } else {
            NotificationCenter.default.post(name: Notification.Name("success-FB-login"), object: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
}
