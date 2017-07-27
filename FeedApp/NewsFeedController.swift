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
    
    var mainManagedObjectContext = CoreDataManager.shared.persistentContainer.viewContext
//    lazy var backgroundManagedContext: NSManagedObjectContext = {
//        let context = CoreDataManager.shared.persistentContainer.newBackgroundContext()
//        return context
//    } ()
    
    var fetchedResultsControllerTV: NSFetchedResultsController<NewsFeedEntity>!
    var loadingInProgress = false
    
    //colelctionView
    @IBOutlet weak var collectionView: UICollectionView!
    var  shouldReloadCollectionView = false
    var fetchedResultsControllerCV: NSFetchedResultsController<NewsFeedEntity>!
    var blockOperation: BlockOperation!
    
    var headerViewHeight: CGFloat = 220.0

    //MARK: - View controller life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)

        
        tableView.prefetchDataSource = self
        
        (tableView as UIScrollView).delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        
        self.initializeFetchedResultsControllerForCV()
        self.initializeFetchedResultsControllerForTV()
        
        collectionView.contentOffset = CGPoint(x: (collectionView.bounds.width - (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) / CGFloat(2.0), y: 0)
        
        startTimer()
        
    }
    
    func contextDidSave(notification: Notification) {
        let context = notification.object as! NSManagedObjectContext
        if context != mainManagedObjectContext {
            mainManagedObjectContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations:
            {
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.red]
                self.navigationController?.navigationBar.barTintColor = UIColor.white
                self.navigationController?.navigationBar.barStyle = .default
        }, completion: nil)
        SVProgressHUD.dismiss()
    }
    
    //MARK: Initialization
    
    func loadLastNews(showHUD: Bool = false) {
        if showHUD {
            SVProgressHUD.show()
        }
        NetworkManager.shared.getNewestNews { result in
            SVProgressHUD.dismiss()
            switch result {
            case .fail(with: let error):
                self.showAlert(for: error)
            case .success(with: let data):
                let news = data as! [NewsFeedItem]
                CoreDataManager.shared.saveNews(items: news)
            }
       }
    }
    
    func loadNewFromNextPage() {
        guard !loadingInProgress else {
            return
        }
        let rowCount = tableView.numberOfRows(inSection: 0)
        let page = rowCount > 0 ? rowCount / Constants.newsPageCount + 1 : 1
        loadingInProgress = true
        SVProgressHUD.show()
        tableView.isUserInteractionEnabled = false
        NetworkManager.shared.getNews(atPage: page) { result in
            switch result {
            case .fail(with: let error):
                self.showAlert(for: error)
            case .success(with: let data):
                let news = data as! [NewsFeedItem]
                CoreDataManager.shared.saveNews(items: news)
                self.loadingInProgress = false
            }
            SVProgressHUD.dismiss()
            self.tableView.isUserInteractionEnabled = true
        }
    }
    
    func showAlert(for error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - FetchedResultsController
    
    func initializeFetchedResultsControllerForTV() {
        
        let fetchRequest: NSFetchRequest<NewsFeedEntity> = NewsFeedEntity.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        fetchedResultsControllerTV = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainManagedObjectContext, sectionNameKeyPath:nil, cacheName: nil)
        
        fetchedResultsControllerTV.delegate = self
            do {
                try self.fetchedResultsControllerTV.performFetch()
            } catch {
                fatalError("Failed to initialize FetchedResultsController: \(error)")
            }        
    }
    
    func initializeFetchedResultsControllerForCV() {
        
        let fetchRequest: NSFetchRequest<NewsFeedEntity> = NewsFeedEntity.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let predicate = NSPredicate(format: "isPinned == %@", NSNumber(booleanLiteral: true))
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        fetchedResultsControllerCV = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: mainManagedObjectContext, sectionNameKeyPath:nil, cacheName: nil)
        
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
        if deltaOffset <= 0 { //self.view.bounds.width
            loadNewFromNextPage()
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Segues.showDetail.rawValue {
            
            let indexPath: IndexPath?
            var fromTV = false
            
            if sender is UITableViewCell {
                indexPath = tableView.indexPathForSelectedRow
                fromTV = true
            } else {
                indexPath = collectionView.indexPathsForSelectedItems?.first
            }
            
            if let indexPath = indexPath {
                let newsObject = fromTV ?
                    fetchedResultsControllerTV.object(at: indexPath) :
                    fetchedResultsControllerCV.object(at: indexPath)
                
                CoreDataManager.shared.makeNewsRead(news: newsObject)
                let controller = segue.destination as! NewsDetailViewController
                controller.newsItem = newsObject.newsItem
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    //MARK: - Horizontal View
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let headerView = tableView.tableHeaderView {
            var height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            if let pinnedNewsCount = fetchedResultsControllerCV.fetchedObjects?.count,
                pinnedNewsCount < 1 {
                height = 0
            } else {
                height = headerViewHeight
            }
            //Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                UIView.transition(with: headerView, duration: 0.5, options: .curveEaseOut, animations: { 
                    headerFrame.size.height = height
                    headerView.frame = headerFrame
                    self.tableView.tableHeaderView = headerView
                }, completion: nil)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let cells = tableView.visibleCells as! [FeedTableCell]
        cells.forEach{ cell in
            cell.configureTagViews(forWidth: size.width)
            cell.layoutIfNeeded()
        }
    }
    
    //MARK: - Timer
    
    func startTimer() {
        let timer  = Timer.scheduledTimer(withTimeInterval: 30,
                                                   repeats: true) { timer in
                self.loadLastNews(showHUD: false)
        }
        timer.fire()
    }
    
}


