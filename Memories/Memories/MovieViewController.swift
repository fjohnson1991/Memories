//
//  MovieViewController.swift
//  Memories
//
//  Created by Felicity Johnson on 2/8/17.
//  Copyright © 2017 FJ. All rights reserved.
//

import UIKit
import FBSDKShareKit

protocol PopulateSlideshow: class {
    func getImages() -> [UIImage]
}

class MovieViewController: UIViewController, PopulateSlideshow {
    
    let videoView = VideoView()

    override func viewDidLoad() {
        super.viewDidLoad()

        configView()
    }
    
    func configView() {
        // Remove notification observer
        NotificationCenter.default.removeObserver(self, name: Notification.Name("finished-image-selection"), object: nil)
        
        guard let navHeight = self.navigationController?.navigationBar.frame.height else { print("Error calc nav height in initail view"); return }
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
        let video: FBSDKShareVideo = FBSDKShareVideo()
        let content: FBSDKShareVideoContent = FBSDKShareVideoContent()
        video.videoURL = Slideshow.sharedInstance.videoURL
        print("VIDEO URL \(Slideshow.sharedInstance.videoURL)")
        content.video = video
//        content.contentDescription = "LOCATION FROM MAPKIT)"
        FBSDKShareDialog.show(from: self, with: content, delegate: self)
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

// MARK: - Handle FBSDKSharingDelegate protocol
extension MovieViewController: FBSDKSharingDelegate {
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("RESULTS: \(results)")
    }
    
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        print("ERROR: \(error)")
    }
    
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        print("sharerDidCancel")
    }
}
