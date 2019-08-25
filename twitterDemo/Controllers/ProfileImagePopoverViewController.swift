//
//  ProfileImagePopoverViewController.swift
//  twitterDemo
//
//  Created by Jyoti Sanvake on 24/08/19.
//  Copyright © 2019 Technosoft Engineering Projects Ltd. All rights reserved.
//

import UIKit
import SDWebImage

class ProfileImagePopoverViewController: UIViewController, UIViewControllerTransitioningDelegate {

    var imageURL : String?
    @IBOutlet weak var profileImageView: UIImageView!
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        //        if(self){
        self.modalPresentationStyle = .overCurrentContext
        self.transitioningDelegate = self
        //        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.        
        let tapGesture : UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(onTapContainerView(_ :)))
        tapGesture.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapGesture)

        if imageURL != nil{
            let newURL = imageURL?.replacingOccurrences(of: "_normal", with: "") //imageURL?.prefix(count)
            let url = String(newURL!)
            profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            profileImageView.sd_setImage(with: URL.init(string: url), placeholderImage: UIImage.init(named: "twitter_placeholder")) { (image, error, cache, url) in
            }
        }
    }
    @objc func onTapContainerView(_ sender:UITapGestureRecognizer){
        
        self.dismiss(animated: true) {
            
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
