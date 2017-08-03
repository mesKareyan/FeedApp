//
//  NewsFeedController+Realm.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 8/3/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit
import RealmSwift

extension NewsFeedController {
    
    // Observe Results Notifications
    func observeRealmChanges() {
        self.notificationToken = newsItems.addNotificationBlock { [weak self]
            (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                    with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }

    
}
