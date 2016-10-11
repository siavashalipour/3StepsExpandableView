//
//  MapCardView.swift
//  ScrollExpand
//
//  Created by Siavash Abbasalipour on 10/10/16.
//  Copyright © 2016 sa. All rights reserved.
//

import Foundation

final class MapCardView: UIView {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    class func instanceFromNib() -> MapCardView {
        return Bundle.main.loadNibNamed("MapCardView",owner:self,options:nil)!.first as! MapCardView
    }
    
    func setupUI() {
        layer.cornerRadius = 10
    }
    
    func setupWithStore(_ store: MapStore) {
        layer.cornerRadius = 10
        titleLabel.text = store.storeTitle
        subtitleLabel.text = store.storeSubtitle
    }
}
