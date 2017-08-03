//
//  FeedController+CollectionView.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/11/17.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit

extension NewsFeedController : UICollectionViewDelegate,  UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pinnedNewsItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifer.collectionCell, for: indexPath)
        let newsItem = pinnedNewsItems[indexPath.item]
        configureCellForCollectionView(cell, withNews: newsItem)
        return cell
    }
    
    func configureCellForCollectionView(_ cell: UICollectionViewCell, withNews newsEntity: NewsFeedItemRealm) {
        if let cell = cell as? FeedCollectionCell {
            cell.configure(for: newsEntity)
        }
    }
    
}
