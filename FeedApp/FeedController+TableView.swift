//
//  FeedController+TableView.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/11/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit

// MARK: - Table View

extension NewsFeedController  {
    
    // MARK: - Table View Delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifer.tableCell, for: indexPath) as! FeedTableCell
        
        let newsItem = newsItems[indexPath.item]
        cell.news = newsItem
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FeedTableCell else {
            return
        }
        let newsItem  = newsItems[indexPath.item]
        let newsTitle = newsItem.title! as NSString
        let rowHeight = rowHeightsCache.object(forKey: newsTitle)
        if rowHeight == nil {
            rowHeightsCache.setObject(NSNumber(value: Float(cell.bounds.height)), forKey: newsTitle)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let newsTitle = newsItems[indexPath.row].title! as NSString
        if let height = rowHeightsCache.object(forKey: newsTitle) {
            return CGFloat(height.floatValue)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
}

extension NewsFeedController : UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifer.tableCell, for: indexPath) as! FeedTableCell
            let newsItem = newsItems[indexPath.row]
            cell.news = newsItem
        }
    }
    
}
