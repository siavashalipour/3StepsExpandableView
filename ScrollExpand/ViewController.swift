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

enum PanState {
    case halfOpen
    case open
    case close
}
class ViewController: UIViewController {

    var pane: DraggableView!
    let roundedViewHeight: CGFloat = 250
    var paneState: PanState = .close
    var animation: POPSpringAnimation!

    var keyboardHeight: CGFloat = 0
    let size = UIScreen.main.bounds.size
    let bigY = 2177.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

       

        let draggableView = DraggableView(frame:CGRect(x: 0, y: size.height - 70, width: size.width, height: size.height))
        draggableView.delegate = self
        view.addSubview(draggableView)
        pane = draggableView
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
            return CGPoint(x: size.width/2, y: size.height  - 320/4.0)
        case .open:
            return CGPoint(x: size.width/2, y: size.height * 0.53)
        case .close:
            return CGPoint(x: size.width/2, y: size.height * 1.40)

        }
    }
    
    func didPan(_ gesture: UIPanGestureRecognizer) {
        paneState = paneState == .open ? .close : .open
        let vel = animation.velocity as! CGPoint
        animatePaneWithInitialVelocity(vel)
    }
    
    func animatePaneWithInitialVelocity(_ initialVelocity: CGPoint) {
        pane.pop_removeAllAnimations()
        animation = POPSpringAnimation(propertyNamed: kPOPViewCenter)
        animation.velocity = NSValue.init(cgPoint: initialVelocity)
        animation.toValue = NSValue.init(cgPoint: targetPoint())
        animation.springSpeed = 8
        animation.springBounciness = 2
        pane.pop_add(animation, forKey: "animation")
        
    }

}

extension ViewController: DraggableViewDelegate {
    func draggableViewBeganDragging(_ view: DraggableView) {
        view.layer.pop_removeAllAnimations()
    }
    
    func draggableView(_ view: DraggableView, draggingEndedWith velocity: CGPoint) {
        paneState = velocity.y >= 0 ? .close : .open
        paneState = view.center.y > self.view.bounds.height ? .halfOpen : .open
        if velocity.y > 0 && paneState == .open {
            view.endEditing(true)
            paneState = .halfOpen
        } else if velocity.y > 0 && paneState == .halfOpen {
            paneState = .close
        }
        if paneState == .close {
            view.endEditing(true)
        }
        animatePaneWithInitialVelocity(velocity)
    }
    
    func draggableViewSearchBarTapped(_ view: DraggableView) {

    }
    func draggableViewSearchBarCancelled(_ view: DraggableView) {

    }
    
    func keyboardWillShow(_ notification: Notification) {
        let keyboardInfo = (notification as NSNotification).userInfo
        let keyboardFrameBegin = keyboardInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrameBeginRect = keyboardFrameBegin.cgRectValue
        keyboardHeight = keyboardFrameBeginRect.height
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
















