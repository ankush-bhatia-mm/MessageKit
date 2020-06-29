//
//  TouchGesture.swift
//  MessageKit
//
//  Created by Ankush Bhatia on 26/06/20.
//

import Foundation

protocol TouchGestureDelegate: AnyObject {
    func didTouchStart(_ gesture: TouchGestureDelegate)
    func didTouchEnd(_ gesture: TouchGestureDelegate)
}

class TouchGestureDelegate: UIGestureRecognizer {
    
    weak var touchDelegate: TouchGestureDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        touchDelegate?.didTouchStart(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        touchDelegate?.didTouchEnd(self)
    }
}
