//
//  NewsViewController.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/10/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {
    
    @IBOutlet weak var newsImageView:           UIImageView!
    @IBOutlet var      thumbnailImages:         [UIImageView]!
    @IBOutlet weak var galleryPlusImageView:    UIImageView!
    @IBOutlet weak var newsWebView:             UIWebView!
    @IBOutlet weak var titleLabel:              UILabel!
    @IBOutlet weak var categoryLabel:           UILabel!
    @IBOutlet weak var galleryItemsView:        UIView!
    @IBOutlet weak var topView:                 UIView!
    @IBOutlet weak var titleView:               UIView!
    @IBOutlet weak var topViewTopConstraint: NSLayoutConstraint!
    
    var lastTopOffsetY: CGFloat = 0
    let navBarHeight: CGFloat = 60
    var newsItem: NewsItemEntity? {
        didSet {
            // Update the view.
            if self.isViewLoaded {
                configureView()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsWebView.scrollView.delegate = self;
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
    override var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom != .pad
    }
    
    func configureView() {
        
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let offset = CGPoint(x: 0, y: navBarHeight)
        newsWebView.scrollView.contentInset = insets
        newsWebView.scrollView.scrollIndicatorInsets = insets
        newsWebView.scrollView.setContentOffset(offset, animated: false)
        newsWebView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // Update the user interface for the news item.
        if let news = self.newsItem {
            //news title ui
            titleLabel.text = "Title"
            self.title = " / " + "Category"
            self.categoryLabel.text = Date().shortString
            //news main cover Image
//            if let urlString = news.coverPhotoUrl {
//                self.newsImageView.hnk_setImageFromURL(url)
//            }
            //news text content
            //news thumbnail images
        }
    }
}
//MARK: - ScrollView delegate
extension NewsDetailViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === newsWebView.scrollView else {
            return
        }
        guard let _ = self.navigationController?.navigationBar else {
            return
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView === newsWebView.scrollView {
            self.lastTopOffsetY = scrollView.contentOffset.y;
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView === newsWebView.scrollView {
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView === newsWebView.scrollView {
            let hide = newsWebView.scrollView.contentOffset.y > lastTopOffsetY
            setTopView(hidden: hide)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView === newsWebView.scrollView {
        }
    }
    
    func setTopView(hidden isHidden: Bool) {
        topViewTopConstraint.constant =  isHidden ? -360 : 0
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
}

