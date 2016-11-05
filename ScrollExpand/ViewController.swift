//
//  ViewController.swift
//  ScrollExpand
//
//  Created by Siavash Abbasalipour on 10/10/16.
//  Copyright © 2016 sa. All rights reserved.
//

import UIKit
import pop
import MapKit
import SnapKit

enum PanState {
    case halfOpen
    case open
    case close
}
class ViewController: UIViewController {
    
    var pane: DraggableView!
    
    var paneState: PanState = .close {
        
        didSet {
            dimView.isHidden = paneState != .open
        }
    }
    var animation: POPSpringAnimation?
    
    var keyboardHeight: CGFloat = 0
    let size = UIScreen.main.bounds.size
    let bigY = 2177.5
    let vc = UIVisualEffectView(effect: UIBlurEffect.init(style: .light))

    @IBOutlet weak var dimView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let draggableView = DraggableView(frame:CGRect(x: 0, y: size.height - 60, width: size.width, height: size.height))
        draggableView.delegate = self
        draggableView.setupForMapWithViewCornerRadius(10)
        view.addSubview(vc)
        vc.frame = draggableView.frame
        vc.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).withAlphaComponent(0.9)
        vc.contentView.addSubview(draggableView)
        draggableView.snp.makeConstraints { (make) in
            make.edges.equalTo(vc.contentView)
        }
        pane = vc.contentView.subviews.last! as! DraggableView
        var stores: Array<MapStore> = []
        for i in 0..<20 {
            let store = MapStore(storeTitle: "Title \(i)", storeSubtitle: "Subtitle \(i)")
            stores.append(store)
        }
        pane.carouselDataSource = stores
        pane.tableViewDataSource = stores 
        let panRecogniser = UIPanGestureRecognizer(target: self, action: #selector(self.didPan(_:)))
        view.addGestureRecognizer(panRecogniser)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name(rawValue: Notification.Name.UIKeyboardWillShow.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name(rawValue: Notification.Name.UIKeyboardWillHide.rawValue), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func targetPoint() -> CGPoint {
        switch paneState {
        case .halfOpen:
            pane.unhideCarousel()
            return CGPoint(x: size.width/2, y: size.height  * 1.23)
        case .open:
            pane.hideCarousel()
            return CGPoint(x: size.width/2, y: size.height * 0.56)
        case .close:
            pane.unhideCarousel()
            return CGPoint(x: size.width/2, y: size.height * 1.42)
            
        }
    }
    
    func didPan(_ gesture: UIPanGestureRecognizer) {
        if let vel = animation?.velocity as? CGPoint {
            animatePaneWithInitialVelocity(vel)
        }
    }
    
    func animatePaneWithInitialVelocity(_ initialVelocity: CGPoint) {
        vc.pop_removeAllAnimations()
        animation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
        animation?.velocity = NSValue.init(cgPoint: initialVelocity)
        animation?.toValue = NSValue.init(cgPoint: targetPoint())
        animation?.springSpeed = 8
        animation?.springBounciness = 4
        vc.pop_add(animation, forKey: "animation")
        
    }
    
}

extension ViewController: DraggableViewDelegate {
    func draggableViewBeganDragging(_ view: DraggableView) {
        view.layer.pop_removeAllAnimations()
    }
    
    func draggableView(_ view: DraggableView, draggingEndedWith velocity: CGPoint) {
        // toggle paneState
        if paneState == .halfOpen {
            if velocity.y >= 0 {
                paneState = .close
            } else {
                paneState = .open
            }
        } else if paneState == .close {
            if velocity.y < 0 {
                paneState = .halfOpen
            }
        } else if paneState == .open {
            if velocity.y >= 0 {
                paneState = .halfOpen
            }
        }
        if paneState == .close || paneState == .halfOpen {
            view.endEditing(true)
        }
        animatePaneWithInitialVelocity(velocity)
    }
    
    func draggableViewSearchBarTapped(_ view: DraggableView) {
        // handled in KeyboardWillShow
    }
    
    func draggableViewSearchBarCancelled(_ view: DraggableView) {
        // handled in KeyboardWillHide
    }
    
    func keyboardWillShow(_ notification: Notification) {
        keyboardHeight = view.getKeyboardHeighForKeyboardNotification(notification)
        let initialVelocity = CGPoint(x: 0.0, y: -bigY)
        paneState = .open
        animatePaneWithInitialVelocity(initialVelocity)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        keyboardHeight = 0
        let initialVelocity = CGPoint(x: 0.0, y: bigY)
        paneState = .close
        animatePaneWithInitialVelocity(initialVelocity)
    }
}


