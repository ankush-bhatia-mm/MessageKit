//
//  CustomMessageInputBar.swift
//  MessageKit
//
//  Created by Ankush Bhatia on 24/06/20.
//

import UIKit
import InputBarAccessoryView

public protocol CustomMessageInputBarDelegate: AnyObject {
    
    func didTapAddButton(_ view: CustomMessageInputBar,
                         sender: InputBarButtonItem)
    func didHoldDownMicButton(_ view: CustomMessageInputBar,
                              sender: InputBarButtonItem)
    func didReleaseMicButton(_ view: CustomMessageInputBar,
                             sender: InputBarButtonItem)
}

public class CustomMessageInputBar: InputBarAccessoryView {
    
    weak public var inputBarDelegate: CustomMessageInputBarDelegate?
    public weak var micButton: InputBarButtonItem?
    
    private var recordingView: RecordingView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        inputTextView.backgroundColor = .white
        inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 16.0
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        setRightStackViewWidthConstant(to: 38*2, animated: false)
        middleContentViewPadding.right = -38
        separatorLine.isHidden = false
        isTranslucent = false
        setupRightItems()
        setupLeftItems()
    }
    
    private func setupRightItems() {
        let micButton = setupMicButton()
        self.micButton = micButton
        let rightItems = [
            sendButton
                .configure {
                    $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 6, right: 0)
                    if #available(iOS 13.0, *) {
                        $0.image = UIImage(systemName: "paperplane.fill")
                        $0.title = nil
                    } else {
                        $0.title = "Send"
                    }
                    $0.tintColor = .black
                    $0.setSize(CGSize(width: 30, height: 30), animated: false)
                },
            micButton,
            InputBarButtonItem.fixedSpace(2)
        ]
        setStackViewItems(rightItems, forStack: .right, animated: false)
    }
    
    private func setupMicButton() -> InputBarButtonItem {
        let micButton = MicButton(frame: CGRect(0, 0, 30, 30))
        micButton.delegate = self
        return micButton
    }
    
    private func setupLeftItems() {
        let leftItems = [
            makeButton(named:"plus", withTintColor: .black)
                .onTextViewDidChange({ (button, textView) in
                    button.isEnabled = textView.text.isEmpty
                }),
            InputBarButtonItem.fixedSpace(2)
        ]
        setLeftStackViewWidthConstant(to: 28, animated: false)
        setStackViewItems(leftItems, forStack: .left, animated: false)
    }
    
    private func makeButton(named: String, withTintColor color: UIColor) -> InputBarButtonItem {
        return InputBarButtonItem()
            .configure {
                $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
                if #available(iOS 13.0, *) {
                    $0.image = UIImage(systemName: named)
                    $0.title = nil
                } else {
                    $0.title = "Add"
                }
                $0.tintColor = color
                $0.setSize(CGSize(width: 30, height: 30), animated: false)
            }
    }
    
    @objc private func didTapAddButton(_ sender: InputBarButtonItem) {
        inputBarDelegate?.didTapAddButton(self, sender: sender)
    }
}

// MARK: - Recording View Setup
extension CustomMessageInputBar {
    
    private func setupRecordingView() {
        let recordingView = RecordingView()
        addSubview(recordingView)
        recordingView.backgroundColor = .lightGray
        recordingView.delegate = self
        self.recordingView = recordingView
    }
    
    private func removeRecordingView() {
        UIView.animate(withDuration: 0.2) {
            self.recordingView?.clean()
            self.recordingView?.removeFromSuperview()
            self.recordingView = nil
            if #available(iOS 13.0, *) {
                self.backgroundView.backgroundColor = .systemBackground
            } else {
                self.backgroundView.backgroundColor = .white
            }
        }
    }
    
    private func addConstraintsToRecordingView() {
        guard let recordingView = recordingView,
            let micButton = micButton else { return }
        recordingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            recordingView.leadingAnchor.constraint(equalTo: leadingAnchor),
            recordingView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                    constant: -micButton.bounds.size.width
                                                        - padding.left),
            recordingView.topAnchor.constraint(equalTo: topAnchor),
            recordingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension CustomMessageInputBar: RecordingViewDelegate {
    
    func remove(_ view: RecordingView) {
        UIView.animate(withDuration: 0.2, animations: {
            self.micButton?.transform = .identity
        }) { (_) in
            self.removeRecordingView()
        }
    }
}

extension CustomMessageInputBar: MicButtonDelegate {
    
    func micButton(_ button: MicButton, handlePan state: UIGestureRecognizer.State, translation: CGPoint) {
        recordingView?.handlePan(state, translation: translation)
    }
    
    func didHoldDownMicButton(_ button: MicButton) {
        if recordingView == nil {
            backgroundView.backgroundColor = .lightGray
            setupRecordingView()
            addConstraintsToRecordingView()
        }
        inputBarDelegate?.didHoldDownMicButton(self, sender: button)
    }
    
    func didReleaseMicButton(_ button: MicButton) {
        UIView.animate(withDuration: 0.2, animations: {
            self.micButton?.transform = .identity
        }) { (_) in
            self.removeRecordingView()
        }
        inputBarDelegate?.didReleaseMicButton(self, sender: button)
    }
    
}
