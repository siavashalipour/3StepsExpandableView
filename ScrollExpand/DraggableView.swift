//
//  DraggableView.swift
//  ScrollExpand
//
//  Created by Siavash Abbasalipour on 10/10/16.
//  Copyright © 2016 sa. All rights reserved.
//

import UIKit
import SnapKit

protocol DraggableViewDelegate {
    func draggableView(_ view: DraggableView, draggingEndedWith velocity: CGPoint)
    func draggableViewBeganDragging(_ view: DraggableView)
    func draggableViewSearchBarTapped(_ view: DraggableView)
    func draggableViewSearchBarCancelled(_ view: DraggableView)
}


class DraggableView: UIView {
    
    var delegate: DraggableViewDelegate?
    var searchBar: UISearchBar!
    var tableView: UITableView!
    var cardCarousel: iCarousel! = iCarousel()
    let carouselHeight: CGFloat = 90
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        // add top guid veiw
        let topGuidView = UIView(frame: CGRect(x: bounds.size.width/2.0 - 20, y: 3, width: 40, height: 5))
        topGuidView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        topGuidView.layer.cornerRadius = 2.5
        addSubview(topGuidView)
        
        // add searchBar
        let h: CGFloat = 44
        let w: CGFloat = bounds.size.width - 16
        searchBar = UISearchBar(frame: CGRect(x: 8, y: 8, width: w, height: h))
        searchBar.backgroundImage = nil
        searchBar.delegate = self
        searchBar.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        addSubview(searchBar)
        for subView in searchBar.subviews {
            for view in subView.subviews {
                if view.isKind(of: NSClassFromString("UISearchBarBackground")!) {
                    let imageView = view as! UIImageView
                    imageView.removeFromSuperview()
                }
            }
        }
        // add gesture recogniser
        let recogniser = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(_:)))
        recogniser.delegate = self
        addGestureRecognizer(recogniser)
        backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        alpha = 0.9
        self.layer.cornerRadius = 10
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name(rawValue: Notification.Name.UIKeyboardWillHide.rawValue), object: nil)
        // add carousel
        addCarouselHolder()
        // add tableView
        tableView = UITableView(frame: CGRect(x: frame.origin.x, y: h + 32 + 90, width: frame.size.width, height: frame.size.height), style: .plain)
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
    }
    
    func addCarouselHolder() {
        cardCarousel.type = .linear
        let h: CGFloat = 90
        cardCarousel.dataSource = self
        cardCarousel.delegate = self
        addSubview(cardCarousel)
        cardCarousel.snp.remakeConstraints { (make) in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.height.equalTo(h)
        }
    }
    
    func didPan(_ gesture: UIPanGestureRecognizer) {
        // do not expand on carousel scrolling
        if gesture.velocity(in: self.superview).x < 200 && !(gesture.velocity(in: self.superview).x <= -200) {
            let point = gesture.translation(in: self.superview)
            self.center = CGPoint(x: self.center.x, y: self.center.y + point.y)
            gesture.setTranslation(CGPoint.zero, in: self.superview)
            if gesture.state == .ended {
                var velocity = gesture.velocity(in: self.superview)
                velocity.x = 0
                delegate?.draggableView(self, draggingEndedWith: velocity)
            } else if gesture.state == .began {
                delegate?.draggableViewBeganDragging(self)
            }
        }

    }
    
    func keyboardWillHide(_ notification: Notification) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
extension DraggableView: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 15
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIView
        var innerCardHolderView: MapCardView
        
        //create new view if no view is available for recycling
        if (view == nil) {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            let maxWidth = bounds.size.width-44
            itemView = UIView(frame:CGRect(x:0, y:0, width:maxWidth-44, height:90))
            
            innerCardHolderView = MapCardView.instanceFromNib()
            innerCardHolderView.tag = 1
            itemView.addSubview(innerCardHolderView)
            innerCardHolderView.snp.makeConstraints { (make) in
                make.edges.equalTo(itemView)
            }
        } else {
            //get a reference to the label in the recycled view
            itemView = view!
            innerCardHolderView = itemView.viewWithTag(1) as! MapCardView
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        
        //let anItem = items[index]
        //innerCardHolderView.setupUI(anItem.cornerRadius, barcode: anItem.barcode, loyaltyPoints: anItem.loyaltyPoints)
        innerCardHolderView.setupUI()
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        //        let anItem = items[index]
        //        let aCard = LoyaltyCardView.instanceFromNib()
        //        aCard.setupUI(anItem.cornerRadius, barcode: anItem.barcode, loyaltyPoints: anItem.loyaltyPoints)
        //        selectedloyaltyCard = aCard
        //        performSegue(withIdentifier: editCardSegue, sender: self)
    }
}
extension DraggableView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if (cell == nil) {
            cell  = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        cell?.backgroundColor = UIColor.clear
        cell?.contentView.backgroundColor = UIColor.clear
        cell?.textLabel?.text = "\(indexPath.row).\(indexPath.section) Title"
        return cell!
        
        
    }
}
extension DraggableView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
extension DraggableView: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        delegate?.draggableViewSearchBarTapped(self)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        endEditing(true)
        delegate?.draggableViewSearchBarCancelled(self)
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
