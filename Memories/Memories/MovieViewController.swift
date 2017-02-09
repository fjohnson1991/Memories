//
//  MovieViewController.swift
//  Memories
//
//  Created by Felicity Johnson on 2/8/17.
//  Copyright © 2017 FJ. All rights reserved.
//

import UIKit

protocol PopulateSlideshow: class {
    func getImages() -> [UIImage]
}

class MovieViewController: UIViewController, PopulateSlideshow {

    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configView() {
        // Remove notification observer
        NotificationCenter.default.removeObserver(self, name: Notification.Name("finished-image-selection"), object: nil)
        
        guard let navHeight = self.navigationController?.navigationBar.frame.height else { print("Error calc nav height in initail view"); return }
        let videoView = VideoView()
        self.view.addSubview(videoView)
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: navHeight).isActive = true
        videoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        videoView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: 0).isActive = true
        videoView.delegate = self
        
        // Navigation config
        self.navigationItem.title = "View Your Video!"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(postVideo))
    }
    
    func postVideo() {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MovieViewController {
    func getImages() -> [UIImage] {
        return Slideshow.sharedInstance.images
    }
}
