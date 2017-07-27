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
    
    func configureCellForTableView(_ cell: UITableViewCell, withNews newsEntity: NewsFeedEntity) {
        if let cell = cell as? FeedTableCell {
            cell.configure(for: newsEntity)
        }
    }
    
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let selectedCell = tableView.cellForRow(at: indexPath)
            selectedCell?.contentView.backgroundColor = UIColor.groupTableViewBackground
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifer.tableCell, for: indexPath)
        let newsItem = fetchedResultsControllerTV.object(at: indexPath)
        configureCellForTableView(cell, withNews: newsItem)
        return cell
    }
    
}

extension NewsFeedController : UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifer.tableCell, for: indexPath)
            let newsItem = fetchedResultsControllerTV.object(at: indexPath)
            configureCellForTableView(cell, withNews: newsItem)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        
    }
}
