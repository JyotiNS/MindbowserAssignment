//
//  ProfileDetailsViewController.swift
//  twitterDemo
//
//  Created by Jyoti Sanvake on 22/08/19.
//  Copyright © 2019 Technosoft Engineering Projects Ltd. All rights reserved.
//

import UIKit
import SDWebImage
import TwitterKit
import SVPullToRefresh
import Reachability

class ProfileDetailsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var isFollowersList : Bool?
    var friendsList : [Followers]?
    var selectedImageURL : String?
    var userProfile : TwitterUser?
    var pageNumber : Int = 1
    var next_cursorVal = "-1"
    var activityIndicatorView:UIActivityIndicatorView?
    let reachability = Reachability()!
    var isNetworkReachable : Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }

        activityIndicatorView = UIActivityIndicatorView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicatorView?.style = .whiteLarge
        activityIndicatorView?.color = UIColor.blue
        self.view.addSubview(activityIndicatorView!)
        activityIndicatorView?.center = self.view.center
        // Do any additional setup after loading the view.
        self.tableView.register(UINib.init(nibName: "FriendsTableViewCell", bundle: nil), forCellReuseIdentifier: "FriendsTableViewCellId")
        if self.userProfile != nil {
            self.initScrolling()
            self.friendsList = [Followers]()
            activityIndicatorView?.startAnimating()
            if self.isFollowersList ?? false {
                //load followers
                self.getFollowersList()
            }else{
                //load friends
                self.getFriendsList()
            }
        }
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
    

    func initScrolling(){
        
        self.tableView.addPullToRefresh {
            self.insertRowAtTop()
        }
        self.tableView.addInfiniteScrolling {
            self.insertRowAtBottom()
        }
    }
    func insertRowAtTop(){
        if self.isNetworkReachable{
        next_cursorVal = "-1"
//        self.friendsList = [Followers]()
        if self.isFollowersList ?? false {
            //load followers
            self.getFollowersList()
        }else{
            //load friends
            self.getFriendsList()
            }
        }else{
            let message = "Internet connection is not available"
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //Perform Action
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func insertRowAtBottom(){
        if self.isNetworkReachable{
            if self.isFollowersList ?? false {
                //load followers
                self.getFollowersList()
            }else{
                //load friends
                self.getFriendsList()
            }
        }else{
            let message = "Internet connection is not available"
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //Perform Action
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func getFollowersList(){
        
        if self.isNetworkReachable{
        if let token = self.userProfile?.token, let userId = self.userProfile?.userId {
//        let client = TWTRAPIClient()
        let client = TWTRAPIClient(userID: userId)
        let statusesShowEndpoint = "https://api.twitter.com/1.1/followers/list.json"
            let params = ["Authorization" : "Bearer \(token)" ,"user_id": "\(userId)","skip_status":"true","count": "20", "cursor" : "\(self.next_cursorVal)"]
        var clientError : NSError?

        let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)

        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError)")
            }

            do {
                if data != nil{

                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Any]
                    if self.next_cursorVal == "-1"{
                        self.friendsList = [Followers]()
                    }
                    if let cursorValue = json["next_cursor_str"] as? String{
                        self.next_cursorVal = cursorValue
                    }
                    if let followersArray = json["users"] as? [[String : Any]]{
                       
                        for user in followersArray{
                            let follower = Followers.init(name: user["name"] as! String, profileImageURL: user["profile_image_url"] as! String, profileImageLargeURL: user["profile_image_url_https"] as! String)
                            if self.friendsList?.contains(follower) == false {
                                self.friendsList?.append(follower)
                            }
                        }
                        self.tableView.reloadData()
                        self.activityIndicatorView?.stopAnimating()
                    }
                print("json: \(json)")
                }
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }

        }
    }else{
            let message = "Internet connection is not available"
            let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            //Perform Action
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func getFriendsList(){
        if self.isNetworkReachable{

        if let token = self.userProfile?.token, let userId = self.userProfile?.userId {
            let client = TWTRAPIClient(userID: userId)
            
            let statusesShowEndpoint = "https://api.twitter.com/1.1/friends/list.json"
            
            let params = ["Authorization" : "Bearer \(token)" ,"user_id": "\(userId)","skip_status":"true", "count": "20","cursor" : "\(self.next_cursorVal)"]
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(connectionError)")
                }
                do {
                    if data != nil{
                        
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String : Any]
                        if self.next_cursorVal == "-1"{
                            self.friendsList = [Followers]()
                        }
                        
                        if let cursorValue = json["next_cursor_str"] as? String{
                            self.next_cursorVal = cursorValue
                        }
                        if let followersArray = json["users"] as? [[String : Any]]{
                            print("followersArray \(followersArray)")
                            for user in followersArray{
                                let follower = Followers.init(name: user["name"] as! String, profileImageURL: user["profile_image_url"] as! String, profileImageLargeURL: user["profile_image_url_https"] as! String)
                                if self.friendsList?.contains(follower) == false {
                                    self.friendsList?.append(follower)
                                }
                            }
                            self.tableView.reloadData()
                            self.activityIndicatorView?.stopAnimating()
                        }
                        print("json: \(json)")
                    }
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
            }
            }
        }
    }
    @objc func onProfileImageTap(_ gesture : UITapGestureRecognizer){
        let view = gesture.view
        if (view?.isKind(of: UITableViewCell.self))!{
            
            let currentCell = view as! FriendsTableViewCell
            if let selectedCellObject = currentCell.dataObject{
                
                let profileImageURL = selectedCellObject.profileImageURL
                self.selectedImageURL = profileImageURL
                print("selectedCell image : \(profileImageURL)")
                self.performSegue(withIdentifier: "profileImageViewer", sender: self)
            }
            
        }
        
        
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "profileImageViewer"{
            
            if let profileImageView = segue.destination as? ProfileImagePopoverViewController{
                profileImageView.imageURL = self.selectedImageURL
            }
        }
    }
    

}
extension ProfileDetailsViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80 //UITableView.automaticDimension
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let friendsCell : FriendsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FriendsTableViewCellId") as! FriendsTableViewCell
        
        if let friend = self.friendsList?[indexPath.row] {
        friendsCell.dataObject = friend
        if let profileImageURL = friend.profileImageURL {
            friendsCell.profileImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
            friendsCell.profileImage?.sd_setImage(with: URL.init(string: profileImageURL), placeholderImage: UIImage.init(named: ""), options: .continueInBackground, completed: { (image, error, cache, imageUrl) in
            })
        }
        friendsCell.name.text = friend.name
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(onProfileImageTap(_ :)))
        friendsCell.addGestureRecognizer(tapGesture)
        friendsCell.profileImage.layer.cornerRadius = friendsCell.profileImage.frame.height / 2
        }
        return friendsCell
        
    }
   
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView.init(frame: CGRect.zero)
    }
    
    
    
}

extension ProfileDetailsViewController : UITableViewDelegate{
    
    
    
    
}
