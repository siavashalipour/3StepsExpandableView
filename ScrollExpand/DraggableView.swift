//
//  DraggableView.swift
//  ScrollExpand
//
//  Created by Siavash Abbasalipour on 10/10/16.
//  Copyright © 2016 sa. All rights reserved.
//

import UIKit

protocol DraggableViewDelegate {
    func draggableView(_ view: DraggableView, draggingEndedWith velocity: CGPoint)
    func draggableViewBeganDragging(_ view: DraggableView)
    func draggableViewSearchBarTapped(_ view: DraggableView)
    func draggableViewSearchBarCancelled(_ view: DraggableView)
}


class DraggableView: UIView {
    
    var delegate: DraggableViewDelegate?
    var searchBar: UISearchBar!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        let topGuidView = UIView(frame: CGRect(x: bounds.size.width/2.0 - 20, y: 3, width: 40, height: 5))
        topGuidView.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        topGuidView.layer.cornerRadius = 2.5
        addSubview(topGuidView)
        
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
        let recogniser = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(_:)))

        addGestureRecognizer(recogniser)
        backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        alpha = 0.9
        self.layer.cornerRadius = 10
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name(rawValue: Notification.Name.UIKeyboardWillHide.rawValue), object: nil)
    }
    
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
    
    func keyboardWillHide(_ notification: Notification) {
        searchBar.setShowsCancelButton(false, animated: true)
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
