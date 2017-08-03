//
//  RealmManager.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 8/3/17.
//  Copyright © 2017 none. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    
    static func forceCommit(action: () -> ()) {
        let realm = try! Realm()
        realm.beginWrite()
        action()
        try! realm.commitWrite()
    }
    
}

class RealmManager {
    
    
    static func addNews(items: [NewsFeedItem]) {
    
        DispatchQueue.global(qos: .userInteractive).async {
        
        let realm = try! Realm() // 1

        items.forEach { newsItem in
        
        try! realm.write { // 2
            
            let newsFeedRealm = NewsFeedItemRealm() // 3
            
            newsFeedRealm.date       = newsItem.webPublicationDate.shortNSDate
            newsFeedRealm.id         = newsItem.id
            newsFeedRealm.read       = false
            newsFeedRealm.title      = newsItem.webTitle
            newsFeedRealm.url        = newsItem.webUrl
            newsFeedRealm.category   = newsItem.sectionName
            newsFeedRealm.date       = newsItem.webPublicationDate.shortNSDate
            newsFeedRealm.thumbnail  = newsItem.thumbnail
            
            let newsRealm       = NewsItemRealm()
            newsRealm.id       = newsItem.id
            newsRealm.apiURL   = newsItem.apiUrl
            newsRealm.webURL   = newsItem.webUrl
            newsRealm.feedItem = newsFeedRealm
            newsFeedRealm.newsItem = newsRealm
            
            
            realm.add(newsFeedRealm, update: true)
            realm.add(newsRealm, update: true)
            
            }
        }
    }
    }
    
    static func makeNews(read: Bool,  news: NewsFeedItemRealm) {
        Realm.forceCommit {
            news.read = read
        }
    }
    
    static func makeNews(pinned: Bool, news: NewsFeedItemRealm) {
        Realm.forceCommit {
            news.pinned = pinned
        }
    }
    
    static func saveBody(_ body: String, forNews newsEntity: NewsItemRealm) {
        Realm.forceCommit {
            newsEntity.body =  body.data(using: .utf8)! as NSData
            newsEntity.isSaved = true
        }
    }

    
}
