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

struct MapStore {
    let storeTitle: String
    let storeSubtitle: String
}

class DraggableView: UIView {
    
    var delegate: DraggableViewDelegate?
    var carouselDataSource: Array<MapStore>? {
        didSet {
            addCarouselHolder()
            updateTableViewConstraint()
        }
    }
    
    fileprivate var searchBar: UISearchBar!
    fileprivate var tableView: UITableView!
    fileprivate var cardCarousel: iCarousel?
    fileprivate let carouselHeight: CGFloat = 90
    fileprivate let topGuideHeight: CGFloat = 5
    fileprivate let topGuideWidth: CGFloat = 40
    fileprivate let searchBarHeight: CGFloat = 44
    fileprivate let defaultPadding: CGFloat = 8
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private methods
    fileprivate func setup() {
        // add top guid veiw
        addTopGuide()
        
        // add searchBar
        addSearchBar()
        
        // add gesture recogniser
        let recogniser = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(_:)))
        recogniser.delegate = self
        addGestureRecognizer(recogniser)
        backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        alpha = 0.9
        self.layer.cornerRadius = 10
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name(rawValue: Notification.Name.UIKeyboardWillHide.rawValue), object: nil)

        // add tableView
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
        updateTableViewConstraint()
    }
    
    fileprivate func addCarouselHolder() {
        if cardCarousel == nil {
            cardCarousel = iCarousel()
            cardCarousel?.type = .linear
            cardCarousel?.isPagingEnabled = true
            cardCarousel?.dataSource = self
            cardCarousel?.delegate = self
            addSubview(cardCarousel!)
            cardCarousel?.snp.remakeConstraints { (make) in
                make.left.equalTo(self)
                make.right.equalTo(self)
                make.top.equalTo(searchBar.snp.bottom).offset(defaultPadding)
                make.height.equalTo(carouselHeight)
            }
        }
    }
    
    fileprivate func updateTableViewConstraint() {
        tableView.snp.remakeConstraints { (make) in
            if let safeCarousel = cardCarousel {
                if safeCarousel.isHidden {
                    make.top.equalTo(searchBar.snp.bottom).offset(defaultPadding)
                } else {
                    make.top.equalTo(safeCarousel.snp.bottom).offset(defaultPadding)
                }
            } else {
                make.top.equalTo(searchBar.snp.bottom).offset(defaultPadding)
            }
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
        }
    }
    
    fileprivate func addTopGuide() {
        let topGuidView = UIView(frame: CGRect(x: bounds.size.width/2.0 - topGuideWidth/2, y: 3, width: topGuideWidth, height: topGuideHeight))
        topGuidView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        topGuidView.layer.cornerRadius = 2.5
        addSubview(topGuidView)
    }
    
    fileprivate func addSearchBar() {
        let w: CGFloat = bounds.size.width - 2*defaultPadding
        searchBar = UISearchBar(frame: CGRect(x: defaultPadding, y: defaultPadding, width: w, height: searchBarHeight))
        searchBar.delegate = self
        searchBar.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        addSubview(searchBar)
        for subView in searchBar.subviews {
            for view in subView.subviews {
                guard let searchBarBackgroundClass = NSClassFromString("UISearchBarBackground")  else {
                    return
                }
                if view.isKind(of: searchBarBackgroundClass) {
                    guard let imageView = view as? UIImageView else {
                        return
                    }
                    imageView.removeFromSuperview()
                    return
                }
                
            }
        }
    }
    // MARK: Gesture
    func didPan(_ gesture: UIPanGestureRecognizer) {
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
    // MARK: Notification
    func keyboardWillHide(_ notification: Notification) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    // MARK: Public helper
    func hideCarousel() {
        cardCarousel?.isHidden = true
        updateTableViewConstraint()
        
    }
    
    func unhideCarousel() {
        cardCarousel?.isHidden = false
        updateTableViewConstraint()
        
    }
}
extension DraggableView: iCarouselDataSource, iCarouselDelegate {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return carouselDataSource?.count ?? 0
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIView
        var innerCardHolderView: MapCardView
        
        //create new view if no view is available for recycling
        if let safeView = view {
            //get a reference to the label in the recycled view
            itemView = safeView
            innerCardHolderView = itemView.viewWithTag(1) as! MapCardView
        } else {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            let maxWidth = bounds.size.width - 44
            itemView = UIView(frame:CGRect(x:0, y:0, width:maxWidth - 44, height:carouselHeight))
            
            innerCardHolderView = MapCardView.instanceFromNib()
            innerCardHolderView.tag = 1
            itemView.addSubview(innerCardHolderView)
            innerCardHolderView.snp.makeConstraints { (make) in
                make.edges.equalTo(itemView)
            }
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        let aStore = carouselDataSource?[index]
        innerCardHolderView.setupWithStore(aStore!) // we should crash if we are here and we don't have a Store! :)
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
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
        let identifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if (cell == nil) {
            cell  = UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
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
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = pan.velocity(in: self)
            return fabs(velocity.y) > fabs(velocity.x)
        }
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
