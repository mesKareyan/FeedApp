//
//  NewsFeedController.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD
import NVActivityIndicatorView
import ReachabilitySwift
import RealmSwift

class NewsFeedController: UITableViewController {
    
    //Realm
    
    let realm = try! Realm()
    
    var notificationToken: NotificationToken? = nil
    var pinnedItemsNotificationToken: NotificationToken? = nil

    lazy var newsItems: Results<NewsFeedItemRealm> = {
        self.realm.objects(NewsFeedItemRealm.self)
    }()
    
    var pinnedNewsItems: Results<NewsFeedItemRealm>!
    
    func filterPinnedItems()  {
       pinnedNewsItems = realm.objects(NewsFeedItemRealm.self)
                                .filter("pinned == true")
    }
    
    var blockOperation: BlockOperation!

    
    @IBOutlet weak var footerView: UIView!
    
    var isLoadingInProgress     = false
    var isInitailContentLoaded  = false
    var isNeedToLoadNextPage    = false
    var progressBarConstraint: NSLayoutConstraint!
    
    //colelctionView
    @IBOutlet weak var collectionView: UICollectionView!
    var  shouldReloadCollectionView = false
    let reachability = Reachability()!
    var timer: Timer!

    var headerViewHeight: CGFloat = 220.0

    //MARK: - View controller life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //tableView.prefetchDataSource = self
        
        observeRealmChanges()
        
        (tableView as UIScrollView).delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 500
        footerView.bounds.size.height = 0
        
        collectionView.contentOffset = CGPoint(x: (collectionView.bounds.width - (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width) / CGFloat(2.0), y: 0)
        
        self.loadLastNews(showHUD: true)
        
        // add Footer progress bar
        tableView.decelerationRate = UIScrollViewDecelerationRateFast
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
        filterPinnedItems()
        collectionView.reloadData()
    }
    
    deinit {
        notificationToken?.stop()
    }

    //MARK: Initialization
    
    func initializateNewsFromRealm() {
        
    }
    
    func loadLastNews(showHUD: Bool = false) {
        if showHUD {
            SVProgressHUD.show()
        }
        NetworkManager.shared.getNewestNews { result in
            self.isInitailContentLoaded = true
            switch result {
            case .fail(with: let error):
                DispatchQueue.main.async {
                    self.showAlert(for: error)
                }
            case .success(with: let data):
                let news = data as! [NewsFeedItem]
                DispatchQueue.main.async {
                    self.footerView.bounds.size.height = 60
                    RealmManager.addNews(items: news)
                    SVProgressHUD.dismiss()
                    if showHUD {
                        self.startTimer()
                    }
                    SVProgressHUD.dismiss()
                }
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
                RealmManager.addNews(items: news)
                DispatchQueue.main.async {
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
        let viewWidth = view.bounds.width
        if  deltaOffset <= 100 * viewWidth {
                loadNewFromNextPage()
        }
        if velocity < -50 && deltaOffset <= 0{
            isNeedToLoadNextPage = true
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
                    newsItems[indexPath.row] :
                    newsItems[indexPath.item]
                //make news Read
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
            if  pinnedNewsItems.count < 1 {
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


