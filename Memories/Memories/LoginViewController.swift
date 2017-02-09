//
//  LoginViewController.swift
//  Memories
//
//  Created by Felicity Johnson on 2/9/17.
//  Copyright © 2017 FJ. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configLogin()
        NotificationCenter.default.addObserver(self, selector: #selector(segueToLanding), name: Notification.Name("success-FB-login"), object: nil)
    }

    func configLogin() {
        let loginView = LoginView()
        self.view.addSubview(loginView)
        loginView.translatesAutoresizingMaskIntoConstraints = false
        loginView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 1).isActive = true
        loginView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        loginView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
    }
    
    func segueToLanding() {
        performSegue(withIdentifier: "landingSegue", sender: self)
    }
}
