//
//  ClearAllWidget.swift
//  ecommerce
//
//  Created by Guy Daher on 17/03/2017.
//  Copyright © 2017 Guy Daher. All rights reserved.
//

import UIKit
import InstantSearchCore

@objc public class ClearAllWidget: UIButton, SearcherInterface {

    public var searcher: Searcher! {
        didSet {
            addTarget(self, action: #selector(self.clearFilter), for: .touchUpInside)
        }
    }
    
    internal func clearFilter() {
        searcher.params.clearRefinements()
        NotificationCenter.default.post(name: clearAllFiltersNotification, object: nil)
        searcher.search()
    }

}