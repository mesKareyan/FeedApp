//
//  Constants.swift
//  FeedApp
//
//  Created by Mesrop Kareyan on 7/11/17.
//  Copyright © 2017 none. All rights reserved.
//

import Foundation


struct Constants {
    
    private init () {}
    
    enum Segues : String {
        case  showDetail
    }
    
    struct CellIdentifer {
        private init () {}
        static let tableCell      = "tableCell"
        static let collectionCell = "collectionCell"
    }
    
    struct AnimationDuration {
        private init() {}
        static let showFirstItemForIPad: TimeInterval = 0.4
    }
    
    static let newsPageCount = 20
    
}
