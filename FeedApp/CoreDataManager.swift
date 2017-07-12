//
//  CoewDataManager.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    private init() {}
    
    func saveNews(items news: [NewsFeedItem]) {
        news.forEach { insertNewsObjectsFor(newsItem:  $0)}
    }
    
    func makeNewsRead(news: NewsFeedEntity) {
        news.isRead = true
        self.saveContext()
    }
    
    func saveBody(_ body: String, forNews newsEntity: NewsItemEntity) {
        newsEntity.body =  body.data(using: .utf8)! as NSData
        newsEntity.isSaved = true
        CoreDataManager.shared.saveContext()
    }
    
    private func insertNewsObjectsFor(newsItem: NewsFeedItem) {
        //use shareurl as id for DB
        guard !newsItem.id.isEmpty else {
            return
        }
        let context = self.persistentContainer.viewContext
        let fetch: NSFetchRequest<NewsFeedEntity> = NewsFeedEntity.fetchRequest()
        let predicate   = NSPredicate(format: "id == %@", newsItem.id)
        fetch.predicate = predicate;
        
        //check for dulicates
        if let count = try? context.count(for: fetch),
            count > 0 {
            return
        }
        
        let newsFeedEntity = NewsFeedEntity(context: context)
                
        newsFeedEntity.date       = newsItem.webPublicationDate.shortNSDate
        newsFeedEntity.id         = newsItem.id
        newsFeedEntity.isRead     = false
        newsFeedEntity.title      = newsItem.webTitle
        newsFeedEntity.url        = newsItem.webUrl
        newsFeedEntity.category   = newsItem.sectionName
        newsFeedEntity.date       = newsItem.webPublicationDate.shortNSDate
        newsFeedEntity.thumbnail  = newsItem.thumbnail
        
        let newsEntity      = NewsItemEntity(context: context)
        newsEntity.id       = newsItem.id
        newsEntity.apiURL   = newsItem.apiUrl
        newsEntity.webURL   = newsItem.webUrl
        newsEntity.feedItem = newsFeedEntity
                
        // Save the context.
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "FeedApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
