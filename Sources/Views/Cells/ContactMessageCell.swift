/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit

open class ContactMessageCell: MessageContentCell {
    
    public enum ConstrainsID: String {
        case initialsContainerLeftConstraint
        case disclouserRigtConstraint
    }
    
    /// The view container that holds contact initials
    open lazy var initialsContainerView: UIView = {
        let initialsContainer = UIView(frame: CGRect.zero)
        initialsContainer.backgroundColor = .white
        initialsContainer.layer.shadowColor = UIColor.gray.cgColor
        initialsContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        initialsContainer.layer.shadowRadius = 2
        initialsContainer.layer.shadowOpacity = 0.6
        
        return initialsContainer
    }()
    
    /// The label that display the contact initials
    open lazy var initialsLabel: UILabel = {
        let initialsLabel = UILabel(frame: CGRect.zero)
        initialsLabel.textAlignment = .center
        initialsLabel.textColor = .darkText
        initialsLabel.font = UIFont.preferredFont(forTextStyle: .footnote)

        return initialsLabel
    }()
    
    /// The label that display contact name
    open lazy var nameLabel: UILabel = {
        let nameLabel = UILabel(frame: CGRect.zero)
        nameLabel.numberOfLines = 0
        
        return nameLabel
    }()
    
    /// The disclouser image view
    open lazy var disclouserImageView: UIImageView = {
        let disclouserImage = UIImage.messageKitImageWith(type: .disclouser)?.withRenderingMode(.alwaysTemplate)
        let disclouser = UIImageView(image: disclouserImage)
        
        return disclouser
    }()
    
    // MARK: - Methods
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            nameLabel.font = attributes.messageLabelFont
        }
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(initialsContainerView)
        messageContainerView.addSubview(nameLabel)
        messageContainerView.addSubview(disclouserImageView)
        initialsContainerView.addSubview(initialsLabel)
        
        setupConstraints()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = ""
        initialsLabel.text = ""
    }
    
    open func setupConstraints() {
        initialsContainerView.constraint(equalTo: CGSize(width: 26, height: 26))
        let initialsConstraints = initialsContainerView.addConstraints(left: messageContainerView.leftAnchor, centerY: messageContainerView.centerYAnchor,
                                                        leftConstant: 5)
        initialsConstraints.first?.identifier = ConstrainsID.initialsContainerLeftConstraint.rawValue
        initialsContainerView.layer.cornerRadius = 13
        initialsLabel.fillSuperview()
        disclouserImageView.constraint(equalTo: CGSize(width: 20, height: 20))
        let disclouserConstraints = disclouserImageView.addConstraints(right: messageContainerView.rightAnchor, centerY: messageContainerView.centerYAnchor,
                                           rightConstant: -10)
        disclouserConstraints.first?.identifier = ConstrainsID.disclouserRigtConstraint.rawValue
        nameLabel.addConstraints(messageContainerView.topAnchor,
                                 left: initialsContainerView.rightAnchor,
                                 bottom: messageContainerView.bottomAnchor,
                                 right: disclouserImageView.leftAnchor,
                                 topConstant: 0,
                                 leftConstant: 10,
                                 bottomConstant: 0,
                                 rightConstant: 5)
    }
    
    // MARK: - Configure Cell
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        // setup data
        guard case let .contact(contactItem) = message.kind else { fatalError("Failed decorate audio cell") }
        nameLabel.text = contactItem.getName()
        initialsLabel.text = contactItem.getInitials()
        // setup constraints
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        let initialsContainerLeftConstraint = messageContainerView.constraints.filter { (constraint) -> Bool in
            return constraint.identifier == ConstrainsID.initialsContainerLeftConstraint.rawValue
        }.first
        let disclouserRightConstraint = messageContainerView.constraints.filter { (constraint) -> Bool in
            return constraint.identifier == ConstrainsID.disclouserRigtConstraint.rawValue
        }.first
        if dataSource.isFromCurrentSender(message: message) { // outgoing message
            initialsContainerLeftConstraint?.constant = 5
            disclouserRightConstraint?.constant = -10
        } else { // incoming message
            initialsContainerLeftConstraint?.constant = 10
            disclouserRightConstraint?.constant = -5
        }
        // setup colors
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
        nameLabel.textColor = textColor
        disclouserImageView.tintColor = textColor
    }
    
}
