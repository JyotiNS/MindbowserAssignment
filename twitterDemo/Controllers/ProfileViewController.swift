//
//  ProfileViewController.swift
//  twitterDemo
//
//  Created by Jyoti Sanvake on 22/08/19.
//  Copyright © 2019 Technosoft Engineering Projects Ltd. All rights reserved.
//

import UIKit
import TwitterKit
import SDWebImage
import Reachability

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var followingButton: UIButton!
    @IBOutlet weak var followersButton: UIButton!
    @IBOutlet weak var emailId: UILabel!
    @IBOutlet weak var userName: UILabel!
    var isFollowersList : Bool?
    var userData : TwitterUser?
    var followers : [Followers]?
    var friends : [Followers]?
    let reachability = Reachability()!
    var isNetworkReachable : Bool = true


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }

        if self.userData != nil{
            
            self.userName.text = self.userData?.userName
            self.emailId.text = self.userData?.emailId
            self.loadImage()
            
        }
        profileImage.layer.cornerRadius = self.profileImage.frame.height / 2
        
        let followersCount = "\(self.userData?.followers ?? 0)"
        let friendsCount = "\(self.userData?.friends ?? 0)"
        followingButton.layer.borderWidth = 1.0
        followingButton.layer.borderColor = UIColor.lightGray.cgColor
        followingButton.layer.cornerRadius = 5.0
        followingButton.setTitle("\(friendsCount) Following", for: .normal)
        
        followersButton.layer.borderWidth = 1.0
        followersButton.layer.borderColor = UIColor.lightGray.cgColor
        followersButton.layer.cornerRadius = 5.0
        followersButton.setTitle("\(followersCount) Followers", for: .normal)
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true

    }
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            isNetworkReachable = true
            print("Reachable via WiFi")
            break
        case .cellular:
            isNetworkReachable = true
            print("Reachable via Cellular")
            break
        case .none:
            isNetworkReachable = false
            print("Network not reachable")
            break
        }
    }

    func loadImage(){
        
        if self.isNetworkReachable ?? false{

        if let imageURL = self.userData?.profileImageURL{
            
            let newURL = imageURL.replacingOccurrences(of: "_normal", with: "") //imageURL?.prefix(count)
            self.profileImage?.sd_setImage(with: URL.init(string: newURL), placeholderImage:UIImage.init(named: "twitter_placeholder") , options: .continueInBackground, completed: { (image, error, cache, url) in
            })
        }
        }
    }

    @IBAction func onClickFollowers(_ sender: UIButton){
        
        isFollowersList = true
        self.performSegue(withIdentifier: "profileToDetails", sender: self)
    }
//    func getFollowersData(ids : [String]){
//        
//        
//    }
    @IBAction func onClickFollowingList(_ sender: UIButton) {
        isFollowersList = false
        self.performSegue(withIdentifier: "profileToDetails", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let profileDetailsView : ProfileDetailsViewController = segue.destination as? ProfileDetailsViewController{
            profileDetailsView.isFollowersList = self.isFollowersList
            profileDetailsView.userProfile = self.userData
        }
    }
}
