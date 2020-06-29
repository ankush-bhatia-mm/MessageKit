//
//  TouchGestureRecognizer.swift
//  MessageKit
//
//  Created by Ankush Bhatia on 26/06/20.
//

import Foundation

protocol TouchGestureRecogniserDelegate: AnyObject {
    func didTouchStart(_ gesture: TouchGestureRecognizer)
    func didTouchEnd(_ gesture: TouchGestureRecognizer)
}

class TouchGestureRecognizer: UIGestureRecognizer {
    
    weak var touchDelegate: TouchGestureRecogniserDelegate?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        touchDelegate?.didTouchStart(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        touchDelegate?.didTouchEnd(self)
    }
}
