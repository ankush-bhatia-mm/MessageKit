//
//  CustomMessageInputBar.swift
//  MessageKit
//
//  Created by Ankush Bhatia on 24/06/20.
//

import UIKit
import InputBarAccessoryView

public protocol CustomMessageInputBarDelegate: AnyObject {
    
    func didTapAddButton(_ view: InputBarAccessoryView)
}

public class CustomMessageInputBar: InputBarAccessoryView {
    
    weak public var inputBarDelegate: CustomMessageInputBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        inputTextView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 16.0
        inputTextView.layer.masksToBounds = true
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        setRightStackViewWidthConstant(to: 38, animated: false)
        middleContentViewPadding.right = -38
        separatorLine.isHidden = true
        isTranslucent = true
        setupRightItems()
        setupLeftItems()
    }
    
    private func setupRightItems() {
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
            InputBarButtonItem.fixedSpace(2)
        ]
        setStackViewItems(rightItems, forStack: .right, animated: false)
    }
    
    private func setupLeftItems() {
        let leftItems = [
            makeButton(named:"plus", withTintColor: .black)
                .onTextViewDidChange({ (button, textView) in
                    button.isEnabled = textView.text.isEmpty
                }).onSelected{
                    self.didTapAddButton($0)
            },
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
            }.onSelected {
                $0.tintColor = UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
            }.onDeselected {
                $0.tintColor = color
            }
    }
    
    func didTapAddButton(_ sender: InputBarButtonItem) {
        inputBarDelegate?.didTapAddButton(self)
    }
}
