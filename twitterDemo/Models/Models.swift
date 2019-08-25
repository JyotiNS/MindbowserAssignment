//
//  Models.swift
//  twitterDemo
//
//  Created by Jyoti Sanvake on 23/08/19.
//  Copyright © 2019 Technosoft Engineering Projects Ltd. All rights reserved.
//

import Foundation

public class TwitterUser : NSObject {
    
    var userName : String?
    var emailId : String?
    var profileImageURL : String?
    var profileImageLargeURL : String?
    var userId : String?
    var token : String?
    var followers : Int?
    var friends : Int?
    init(userId : String, userName:String, emailId:String, profileImageURL : String, profileImageLargeURL:String, authToken : String, followers : Int? , friends : Int?) {
        self.userId = userId
        self.userName = userName
        self.emailId = emailId
        self.profileImageURL = profileImageURL
        self.profileImageLargeURL = profileImageLargeURL
        self.token = authToken
        self.followers = followers
        self.friends = friends
    }

    
}


public class Followers : NSObject{
    
    var name : String?
    var profileImageURL : String?
    var profileImageLargeURL : String?
    
    init(name : String, profileImageURL : String, profileImageLargeURL : String) {
        
        self.name = name
        self.profileImageURL = profileImageURL
        self.profileImageLargeURL = profileImageLargeURL
    }
    
}
