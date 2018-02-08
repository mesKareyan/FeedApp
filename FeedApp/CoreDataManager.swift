//
//  CoewDataManager.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//
//FeedApp
import Foundation
import CoreData

class CoreDataStack {
    
    private init () {
        setupNotificationHandling()
    }
    
    static let shared = CoreDataStack()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FeedApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveDefaultContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveMainContext () {
        let context = self.mainManagedObjectContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // MARK: - Notification Handling
    
    @objc func saveChanges(_ notification: NSNotification) {
        mainManagedObjectContext.perform {
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
            
            self.privateManagedObjectContext.perform {
                do {
                    if self.privateManagedObjectContext.hasChanges {
                        try self.privateManagedObjectContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print("Unable to Save Changes of Private Managed Object Context")
                    print("\(saveError), \(saveError.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Contexts
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        return managedObjectContext
    }()
    private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.privateManagedObjectContext
        return managedObjectContext
    }()
    
    func backgroudChildContext() -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.parent = self.mainManagedObjectContext
        return managedObjectContext
    }

    func saveNews(items news: [NewsFeedItem]) {
        let bgContext = self.backgroudChildContext()
        bgContext.perform {
            news.forEach {
                self.insertNewsObjectsFor(newsItem: $0, toContext: bgContext)
            }
            try! bgContext.save()
        }
    }
    
    func makeNewsRead(news: NewsFeedEntity) {
        news.isRead = true
        self.saveMainContext()
    }
    
    func saveBody(_ body: String, forNews newsEntity: NewsItemEntity) {
        newsEntity.body =  body.data(using: .utf8)! as NSData
        newsEntity.isSaved = true
        saveMainContext()
    }
    
    private func insertNewsObjectsFor(newsItem: NewsFeedItem, toContext context: NSManagedObjectContext) {
        //use shareurl as id for DB
        guard !newsItem.id.isEmpty else {
            return
        }
        
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
    
    }
    
}
