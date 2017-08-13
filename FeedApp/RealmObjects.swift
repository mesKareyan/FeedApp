//
//  RealmObjects.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 8/3/17.
//  Copyright © 2017 none. All rights reserved.
//

import Foundation
import RealmSwift

class NewsFeedItemRealm: Object {
    
    dynamic  var pinned:        Bool = false
    dynamic  var read:          Bool = false
    dynamic  var category:      String?
    dynamic  var date:          NSDate?
    dynamic  var id:            String?
    dynamic  var thumbnailURL:  String?
    dynamic  var title:         String?
    dynamic  var url:           String?
    dynamic  var newsItem:      NewsItemRealm?
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

class NewsItemRealm: Object {
    
    dynamic  var isSaved:   Bool = false
    dynamic  var apiURL:    String?
    dynamic  var body:      NSData?
    dynamic  var id:        String?
    dynamic  var webURL:    String?
    dynamic  var feedItem:  NewsFeedItemRealm?
    
    override static func primaryKey() -> String? {
        return "webURL"
    }
    
}
