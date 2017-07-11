//
//  NewsFeedItem.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import Foundation

struct NewsFeedItem {
    
    let id:                 String
    let type:               String
    let sectionId:          String
    let sectionName:        String
    let webPublicationDate: String
    var webTitle:           String
    var webUrl:             String
    let apiUrl:             String
    let isHosted:           Bool
    let thumbnail:          String
    var isPinned:           Bool = false
    
    init(with data: [String: Any]) {
        
        id                  = data["id"]                 as? String ?? ""
        type                = data["type"]               as? String ?? ""
        sectionId           = data["sectionId"]          as? String ?? ""
        sectionName         = data["sectionName"]        as? String ?? ""
        webPublicationDate  = data["webPublicationDate"] as? String ?? ""
        webTitle            = data["webTitle"]           as? String ?? ""
        webUrl              = data["webUrl"]             as? String ?? ""
        apiUrl              = data["apiUrl"]             as? String ?? ""
        isHosted            = data["isHosted"]           as? Bool   ?? false
        let filelds  = data["fields"] as? [String: Any]
        thumbnail    = filelds?["thumbnail"] as? String ?? ""
    
    }
    
}
