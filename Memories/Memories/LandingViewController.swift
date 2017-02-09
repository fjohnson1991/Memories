//
//  ViewController.swift
//  Memories
//
//  Created by Felicity Johnson on 2/7/17.
//  Copyright © 2017 FJ. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Memories"
        NotificationCenter.default.addObserver(self, selector: #selector(dismissImagePickerViewAndDisplayImageCollectionView), name: Notification.Name("finished-image-selection"), object: nil)
        configLayout()
    }
    
    lazy var imageCollectionView = UICollectionView()
    lazy var imagePickerView: ImagePickerView = {
        return ImagePickerView()
    }()
        
    // MARK: - Actions
    func configLayout() {
        // Config view
        guard let navHeight = self.navigationController?.navigationBar.frame.height else { print("Error calc nav height in initail view"); return }
        let initialView = InitialView()
        self.view.addSubview(initialView)
        initialView.translatesAutoresizingMaskIntoConstraints = false
        initialView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: navHeight).isActive = true
        initialView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        initialView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        initialView.selectImagesButton.addTarget(self, action: #selector(selectImagesButtonPressed), for: .touchUpInside)
    }
    
    func selectImagesButtonPressed() {
        self.view.addSubview(imagePickerView)
        imagePickerView.translatesAutoresizingMaskIntoConstraints = false
        guard let navBottomAnchor = self.navigationController?.navigationBar.bottomAnchor else { print("Error retrieving nav bottom anchor in imagePickerView config");return }
        imagePickerView.topAnchor.constraint(equalTo: navBottomAnchor, constant: 0).isActive = true
        imagePickerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        imagePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        present(imagePickerView.imagePicker, animated: true, completion: nil)
    }
    
    func dismissImagePickerViewAndDisplayImageCollectionView() {
        print("notification received")
        imagePickerView.imagePicker.dismiss(animated: true, completion: nil)
        self.performSegue(withIdentifier: "displayMemories", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "displayMemories" {
            _ = segue.destination as! SelectedImagesCollectionViewController
        }
    }
}

