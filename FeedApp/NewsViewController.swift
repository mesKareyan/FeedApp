//
//  NewsViewController.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {
    
    
    @IBOutlet weak var newsWebView:             UIWebView!

    var newsFeedItem: NewsFeedEntity? {
        didSet {
            // Update the view.
            if self.isViewLoaded {
                configureView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.navigationBar.barTintColor = UIColor.red
            self.navigationController?.navigationBar.barStyle = .black
        }
    }
    
    override var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
    }
    
    func configureView() {
        // Update the user interface for the news item.
        if let feedData = self.newsFeedItem {
            //news title ui
            self.title = self.newsFeedItem?.category
            if let newsItem = feedData.newsItem,
                let webUrlString = newsItem.webURL,
                let url = URL(string: webUrlString)
            {
                let request = URLRequest(url: url)
                self.newsWebView.loadRequest(request)
            }
            saveData()
        }
    }
    
    func saveData() {
        
    }
    
    
}

