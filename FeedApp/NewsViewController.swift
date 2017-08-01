//
//  NewsViewController.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit
import SVProgressHUD
import ReachabilitySwift

class NewsDetailViewController: UIViewController {
    
    let reachability = Reachability()!
    var isOfflineMode = false
    var isPageLoaded  = false
    @IBOutlet weak var newsWebView: UIWebView!

    var newsItem: NewsItemEntity! {
        didSet {
            newsItem.feedItem?.isRead = true
            CoreDataManager.shared.saveContext()
            // Update the view.
            if self.isViewLoaded {
                configureView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsWebView.delegate = self
        configureView()
        startReachibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.appRed
            self.navigationController?.navigationBar.barStyle = .black
        }
    }
    
    func startReachibility() {
        
        reachability.whenReachable = { [unowned self] reachability in
            // this is called on a background thread
            DispatchQueue.main.async {
                self.reloadPage()
            }
        }
        reachability.whenUnreachable = { [unowned self] reachability in
            // this is called on a background thread
            guard !self.isPageLoaded else {
                return
            }
            DispatchQueue.main.async {
                if self.newsItem.isSaved {
                    self.loadSavedBody()
                }
                SVProgressHUD.showError(withStatus: "No internet conection")
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    SVProgressHUD.dismiss()
                }

            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
    }
    
    func configureView() {
        
        SVProgressHUD.show()
        
        if let newsItem = self.newsItem {
            if let feedItem = newsItem.feedItem {
                title = feedItem.category
                navigationItem
                    .rightBarButtonItems![1]
                    .isEnabled = !feedItem.isPinned
                reloadPage()
            }
        }
    }
    
    func reloadPage() {
        isOfflineMode = false
        if let webUrlString = newsItem.webURL,
            let url = URL(string: webUrlString)
        {
            let request = URLRequest(url: url)
            self.newsWebView.loadRequest(request)
        }
    }
    
    @IBAction func pinButtonTapped(_ sender: UIBarButtonItem) {
        self.newsItem.feedItem?.isPinned = true
        CoreDataManager.shared.saveContext()
        sender.isEnabled = false
    }
    
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
        
        guard  let newsItem = self.newsItem,
                let _ = newsItem.feedItem else {return }
        
        let message:    String = ""
        let title:      String
        let actionText: String
        
        if newsItem.isSaved {
            if isOfflineMode {
                title      =  "Reload page?"
                actionText =  "Reload"
            } else {
                title      =  "Open saved version of article?"
                actionText =  "Open"
            }
        } else {
            title      =  "Save article for offline use?"
            actionText =  "Save"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        alert.popoverPresentationController?.barButtonItem = sender
        
        alert.addAction(UIAlertAction(title: actionText, style: .default)
        { _ in
            if newsItem.isSaved {
                if self.isOfflineMode {
                    self.reloadPage()
                } else {
                    self.loadSavedBody()
                }
            } else {
                 self.saveBody()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    private func saveBody() {
        guard  let newsItem = self.newsItem,
            let feedItem = newsItem.feedItem else {return }
        NetworkManager.shared.getBodyFor(newsItem: feedItem, completion: { result in
            switch result {
            case .fail(with: let error):
                print(error)
            case .success(with: let body):
                let bodyString = body as! String
                CoreDataManager
                    .shared
                    .saveBody(bodyString,
                              forNews: newsItem)
            }
        })
    }
    
    private func loadSavedBody() {
        let bodyString = String(data: newsItem.body! as Data, encoding: .utf8)
        newsWebView.loadHTMLString(
            bodyString!,
            baseURL: URL(string: newsItem.webURL!))
        isOfflineMode = true
    }

}


extension NewsDetailViewController : UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        isPageLoaded = false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
        isPageLoaded = true
    }
}
