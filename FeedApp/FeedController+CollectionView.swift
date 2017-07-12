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
         return fetchedResultsControllerCV.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsControllerCV.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellIdentifer.collectionCell, for: indexPath)
        let newsItem = fetchedResultsControllerCV.object(at: indexPath)
        configureCellForCollectionView(cell, withNews: newsItem)
        return cell
    }
    
    
    func configureCellForCollectionView(_ cell: UICollectionViewCell, withNews newsEntity: NewsFeedEntity) {
        if let cell = cell as? FeedCollectionCell {
            cell.configure(for: newsEntity)
        }
    }
    
    
}
