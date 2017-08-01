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
import NVActivityIndicatorView
import ReachabilitySwift

class NewsFeedController: UITableViewController {

    
    var mainManagedObjectContext = CoreDataManager.shared.persistentContainer.viewContext

    @IBOutlet weak var footerView: UIView!
    
    var fetchedResultsControllerTV: NSFetchedResultsController<NewsFeedEntity>!
    var isLoadingInProgress     = false
    var isInitailContentLoaded  = false
    var isNeedToLoadNextPage    = false
    var progressBarConstraint: NSLayoutConstraint!
    
    //colelctionView
    @IBOutlet weak var collectionView: UICollectionView!
    var  shouldReloadCollectionView = false
    var fetchedResultsControllerCV: NSFetchedResultsController<NewsFeedEntity>!
    var blockOperation: BlockOperation!
    let reachability = Reachability()!
    var timer: Timer!

    var headerViewHeight: CGFloat = 220.0

    //MARK: - View controller life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        (tableView as UIScrollView).delegate = self
        tableView.decelerationRate = UIScrollViewDecelerationRateFast
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        
        self.initializeFetchedResultsControllerForCV()
        self.initializeFetchedResultsControllerForTV()
        
        collectionView.contentOffset = CGPoint(x: (collectionView.bounds.width - (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) / CGFloat(2.0), y: 0)
        
        self.loadLastNews(showHUD: true)
        
        // add Footer progress bar
        footerView.bounds.size.height = 0
        let frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50)
        footerView.backgroundColor = .appRed
        let progressBar = NVActivityIndicatorView(frame: frame,
                                                  type: .ballPulseSync,
                                                  color: .white,
                                                  padding: 0)
        footerView.addSubview(progressBar)
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.leftAnchor.constraint(equalTo: tableView.leftAnchor).isActive = true
        progressBar.rightAnchor.constraint(equalTo: tableView.rightAnchor).isActive = true
        progressBar.topAnchor.constraint(equalTo: footerView.topAnchor).isActive = true
        progressBarConstraint = progressBar.heightAnchor.constraint(equalToConstant: 0)
        progressBarConstraint.isActive = true
        progressBar.startAnimating()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseOut, animations:
            {
                self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.red]
                self.navigationController?.navigationBar.barTintColor = UIColor.white
                self.navigationController?.navigationBar.barStyle = .default
                self.navigationController!.navigationBar.tintColor = .appRed
        }, completion: nil)
        if isInitailContentLoaded {
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK: Initialization
    
    func loadLastNews(showHUD: Bool = false) {
        if showHUD {
            SVProgressHUD.show()
        }
        NetworkManager.shared.getNewestNews { result in
            SVProgressHUD.dismiss()
            self.isInitailContentLoaded = true
            switch result {
            case .fail(with: let error):
                self.showAlert(for: error)
            case .success(with: let data):
                let news = data as! [NewsFeedItem]
                CoreDataManager.shared.saveNews(items: news)
                if showHUD {
                    self.startTimer()
                }
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func loadNewFromNextPage() {
        guard !isLoadingInProgress else {
            return
        }
        isNeedToLoadNextPage = false
        let rowCount = tableView.numberOfRows(inSection: 0)
        let page = rowCount > 0 ? rowCount / Constants.newsPageCount + 1 : 1
        isLoadingInProgress = true
        NetworkManager.shared.getNews(atPage: page) { result in
            self.isLoadingInProgress = false
            switch result {
            case .fail(with: let error):
                DispatchQueue.main.async {
                    self.showAlert(for: error)
                }
            case .success(with: let data):
                let news = data as! [NewsFeedItem]
                CoreDataManager.shared.saveNews(items: news)
                DispatchQueue.main.async {
                    self.footerView.frame.size.height = 100
                    self.tableView.backgroundColor = .appRed
                }
            }
        }
    }
    
    func showAlert(for error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func topButtonTapped(_ sender: UIBarButtonItem) {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
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
        //check velocity
        let velocity = Double(scrollView.panGestureRecognizer.velocity(in:  view).y)
        let isScrolledSlowlyToBottom = (-50.0..<0).contains(velocity)
        if  isScrolledSlowlyToBottom && deltaOffset <= 0 {
                loadNewFromNextPage()
        }
        if velocity < -50 && deltaOffset <= 0{
            isNeedToLoadNextPage = true
        }
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == tableView else {
            return
        }
        //check velocity
        let velocity = Double(scrollView.panGestureRecognizer.velocity(in:  view).y)
        let isScrolledSlowlyToBottom = (-50.0...0).contains(velocity)
        guard isScrolledSlowlyToBottom else {
            return
        }
        let position = footerView.superview!.convert(footerView.frame.origin , to: nil).y
        let screenHeight = view.bounds.height
        let positionFromBottom = screenHeight - position
        
        if isNeedToLoadNextPage || positionFromBottom > 30 {
            loadNewFromNextPage()
        }
    }
    
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
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
        timer  = Timer.scheduledTimer(withTimeInterval: 30,
                                                   repeats: true) { timer in
                self.loadLastNews(showHUD: false)
        }
        timer.fire()
    }
    
}

//MARK: - Reachinlity
extension NewsFeedController {
    
    func startReachibility() {
        
        reachability.whenReachable = { [unowned self] reachability in
            // this is called on a background thread
            DispatchQueue.main.async {
                self.startTimer()
            }
        }
        
        reachability.whenUnreachable = { [unowned self] reachability in
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
}


