//
//  ViewController.swift
//  twitterDemo
//
//  Created by Jyoti Sanvake on 22/08/19.
//  Copyright © 2019 Technosoft Engineering Projects Ltd. All rights reserved.
//

import UIKit
import TwitterKit
import Reachability

class ViewController: UIViewController {

    var userData : TwitterUser?
    var userId : String?
    var recivedEmailID = ""
    var session : TWTRSession?
    let reachability = Reachability()!
    var isNetworkReachable : Bool?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }

        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                self.session = session
                let twitterClient = TWTRAPIClient(userID: session?.userID)
                self.userId = session?.userID
                twitterClient.requestEmail { email, error in
                    if (email != nil) {
                        self.recivedEmailID = email ?? ""

                    }else {
                        print("error--: \(String(describing: error?.localizedDescription))");
                    }
                }
                if self.isNetworkReachable ?? false {
                    self.getUserData()
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

            } else {
                print("error: \(error?.localizedDescription)");
                let message = error?.localizedDescription
                let alert = UIAlertController(title: "", message: message, preferredStyle: UIAlertController.Style.alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    //Perform Action
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
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

    func getUserData(){
        //        let client = TWTRAPIClient()
        if let userId = self.userId{
        let client = TWTRAPIClient(userID: userId)
        let statusesShowEndpoint = "https://api.twitter.com/1.1/users/lookup.json"
        let params = ["user_id": "\(userId)"]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError)")
            }
            
            do {
                if data != nil{
                    
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [Any]{
                        
                    let userObject = json[0] as! [String : Any]
                    let followersCount = userObject["followers_count"]
                    let friendsCount = userObject["friends_count"]
                   
                    client.loadUser(withID: userId) {(user, error) in
                        let userobject = TwitterUser.init( userId: user?.userID ?? "", userName: user?.name ?? "", emailId:self.recivedEmailID , profileImageURL: user?.profileImageURL ?? "", profileImageLargeURL: user?.profileImageLargeURL ?? "", authToken: self.session?.authToken ?? "",followers: followersCount as? Int, friends: friendsCount as? Int)
                        if userobject != nil{
                            self.userData = userobject
                        }
                        
                        self.performSegue(withIdentifier: "loginToProfile", sender: self)

                    }
                    
                    print("json: \(json)")
                    }
                }
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToProfile" {
            if let profileView = segue.destination as? ProfileViewController{
                profileView.userData = self.userData
            }
        }
        
    }
}

