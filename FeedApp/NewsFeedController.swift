//
//  NewsFeedController.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//


import UIKit
import CoreData
import Haneke
import SVProgressHUD

class NewsFeedController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var fetchedResultsControllerTV: NSFetchedResultsController<NewsFeedEntity>!
    var loadingInProgress = false
    
    //colelctionView
    
    @IBOutlet weak var collectionView: UICollectionView!
    var  shouldReloadCollectionView = false
    var fetchedResultsControllerCV: NSFetchedResultsController<NewsFeedEntity>!
    var blockOperations: [BlockOperation] = []
    var blockOperation: BlockOperation!

    
    //MARK: - View controller life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        (tableView as UIScrollView).delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        self.initializeFetchedResultsControllerForCV()
        self.initializeFetchedResultsControllerForTV()

        //add table view refresh control action
        
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: UIControlEvents.valueChanged)
        loadNews(showHUD: true)
        
        collectionView.contentOffset = CGPoint(x: (collectionView.bounds.width - (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) / CGFloat(2.0), y: 0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations:
            {
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.red]
                self.navigationController?.navigationBar.barTintColor = UIColor.white
                self.navigationController?.navigationBar.barStyle = .default
        }, completion: nil)
    }
    
    func loadNews(showHUD: Bool = false) {
        SVProgressHUD.show()
        NetworkManager.shared.getNewestNews { result in
            SVProgressHUD.dismiss()
            switch result {
            case .fail(with: let error):
                self.showAlert(for: error)
            case .success(with: let data):
                let news = data as! [NewsFeedItem]
                CoreDataManager.shared.saveNews(items: news)
                for var newsItem in news {
                    newsItem.isPinned = true
                }
            }
       }
    }
    
    func loadNewFromNextPage() {
        guard !loadingInProgress else {
            return
        }
        loadingInProgress = true
        let page = tableView.numberOfRows(inSection: 0) / Constants.newsPageCount + 1
        title = "Loading page \(page) index \(index) count\(tableView.numberOfRows(inSection: 0))"
        SVProgressHUD.show()
        NetworkManager.shared.getNews(atPage: page) { result in
            SVProgressHUD.dismiss()
            switch result {
            case .fail(with: let error):
                self.showAlert(for: error)
            case .success(with: let data):
                let news = data as! [NewsFeedItem]
                CoreDataManager.shared.saveNews(items: news)
                self.loadingInProgress = false
            }
        }
    }
    
    func showAlert(for error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - FetchedResultsController
    
    func initializeFetchedResultsControllerForTV() {
        
        self.managedObjectContext = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NewsFeedEntity> = NewsFeedEntity.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        fetchedResultsControllerTV = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath:nil, cacheName: nil)
        
        fetchedResultsControllerTV.delegate = self
        
        do {
            try fetchedResultsControllerTV.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }
    
    func initializeFetchedResultsControllerForCV() {
        
        self.managedObjectContext = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NewsFeedEntity> = NewsFeedEntity.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let predicate = NSPredicate(format: "isPinned == %@", NSNumber(booleanLiteral: false))
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        fetchedResultsControllerCV = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath:nil, cacheName: nil)
        
        fetchedResultsControllerCV.delegate = self
        
        do {
            try fetchedResultsControllerCV.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }
    
    //MARK: - ScrollView delegate 
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == tableView else {
            return
        }
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        print(deltaOffset)
        if deltaOffset <= 1000 {
            loadNewFromNextPage()
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.showDetail.rawValue {
            if let indexPath = tableView.indexPathForSelectedRow {
                let newsObject = fetchedResultsControllerTV.object(at: indexPath)
                CoreDataManager.shared.makeNewsRead(news: newsObject)
                let controller = segue.destination as! NewsDetailViewController
                controller.newsFeedItem = newsObject
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }
    
    
    deinit {
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
}


