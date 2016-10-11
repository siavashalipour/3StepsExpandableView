//
//  Extensions.swift
//  ScrollExpand
//
//  Created by Siavash Abbasalipour on 11/10/16.
//  Copyright © 2016 sa. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func getKeyboardHeighForKeyboardNotification(_ notification: Notification) -> CGFloat {
        let keyboardInfo = (notification as NSNotification).userInfo
        let keyboardFrameBegin = keyboardInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardFrameBeginRect = keyboardFrameBegin.cgRectValue
        return keyboardFrameBeginRect.height
    }
}
