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
        return fetchedResultsControllerTV.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsControllerTV.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchedResultsControllerTV.sections?[section] else { fatalError("Unexpected Section") }
        return sectionInfo.name
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifer.tableCell, for: indexPath) as! FeedTableCell
        let newsItem = fetchedResultsControllerTV.object(at: indexPath)
        cell.configure(for: newsItem)
        
        return cell
    }
    
    
}

extension NewsFeedController : UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifer.tableCell, for: indexPath) as! FeedTableCell
            let newsItem = fetchedResultsControllerTV.object(at: indexPath)
            cell.configure(for: newsItem)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
    }
}
