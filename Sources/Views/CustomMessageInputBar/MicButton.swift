//
//  MicButton.swift
//  MessageKit
//
//  Created by Ankush Bhatia on 26/06/20.
//

import UIKit
import InputBarAccessoryView
protocol MicButtonDelegate: AnyObject {
    
    func micButton(_ button: MicButton,
                   handlePan state: UIGestureRecognizer.State,
                   translation: CGPoint)
    func didHoldDownMicButton(_ button: MicButton)
    func didReleaseMicButton(_ button: MicButton)
}

class MicButton: InputBarButtonItem {
    
    private var panGesture: UIPanGestureRecognizer?
    private var touchGesture: TouchGestureRecognizer?
    
    weak var delegate: MicButtonDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func setup() {
        super.setup()
        if #available(iOS 13.0, *) {
            setImage(UIImage(systemName: "mic.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        tintColor = .black
        setTitleColor(.black, for: .normal)
        setSize(CGSize(width: 30, height: 30), animated: false)
        contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
        addPanGesture()
        addTouchGesture()
    }
    
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.panGesture = panGesture
        addGestureRecognizer(panGesture)
    }
    
    private func removePanGesture() {
        guard let panGesture = panGesture else {
            return
        }
        removeGestureRecognizer(panGesture)
        self.panGesture = nil
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let button = sender.view else {
            return
        }
        let translation = sender.translation(in: button)
        delegate?.micButton(self,
                            handlePan: sender.state,
                            translation: translation)
    }
    
    private func addTouchGesture() {
        let touchGesture = TouchGestureRecognizer(target: self, action: #selector(handleTouch(_:)))
        touchGesture.touchDelegate = self
        self.touchGesture = touchGesture
        addGestureRecognizer(touchGesture)
    }
    
    private func removeTouchGesture() {
        guard let touchGesture = touchGesture else {
            return
        }
        removeGestureRecognizer(touchGesture)
        self.touchGesture = nil
    }
    
    @objc private func handleTouch(_ sender: UIPanGestureRecognizer) {}

}

extension MicButton: TouchGestureRecogniserDelegate {
    
    func didTouchStart(_ gesture: TouchGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { (_) in
            self.delegate?.didHoldDownMicButton(self)
        }
    }
    
    func didTouchEnd(_ gesture: TouchGestureRecognizer) {
        self.delegate?.didReleaseMicButton(self)
    }
}
