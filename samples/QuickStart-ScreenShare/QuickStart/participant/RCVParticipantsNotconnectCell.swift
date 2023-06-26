//
//  RCVParticipantsNotconnectCell.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

class RCVParticipantsNotconnectCell: UITableViewCell {
    private var avatarView: RCVMeetingAvatarView!
//    private var stackView: UIStackView!
    var audioButtonWidthConstraint: NSLayoutConstraint?
    
    var hostIndicatorImageView: UIView = {
        let hostIconHeight = ParticipantLayout.hostIconHeight
        let contentView = UIView()
        contentView.frame = CGRect(x: 0, y: 0, width: hostIconHeight, height: hostIconHeight)
        contentView.backgroundColor = .clear//RCVColor.get(.neutralB01)
        contentView.layer.cornerRadius = hostIconHeight / 2.0

        let innerHeight = hostIconHeight - 4.0
        let innerView = UIView()
        innerView.frame = CGRect(x: 2, y: 2, width: innerHeight, height: innerHeight)
        innerView.backgroundColor = .clear//RCVColor.get(.warningF02)
        innerView.layer.cornerRadius = innerHeight / 2.0
        contentView.addSubview(innerView)

        let label = UILabel(frame: contentView.bounds)
        label.font = UIFont(name: "Arial", size: 10)
        label.text = "\u{e9fc}"
        label.textAlignment = .center
        label.textColor = RCVColor.get(.neutralF01)
        contentView.addSubview(label)

        return contentView
    }()
    
    var statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = UIView.ContentMode.center
        imageView.accessibilityIdentifier = "statusImageView"
        return imageView
    }()
    
    var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = NSTextAlignment.left
        
        var font = UIFont.preferredFont(forTextStyle: .callout)
        if font.pointSize > UIFont.preferredFontMaximumSize(.callout) {
            let fontSize = UIFont.preferredFontMaximumSize(.callout)
            let weight = UIFont.preferredFontDefaultWeight(.callout)
            font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        }
        titleLabel.font = font
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityIdentifier = "titleLabel"
        titleLabel.backgroundColor = .clear
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        return titleLabel
    }()
    
    var stautsContentView: ParticipantStatusContentView = {
        let view = ParticipantStatusContentView()
        return view
    }()
    
    var devicesLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.left
        var font = UIFont.preferredFont(forTextStyle: .footnote)
        if font.pointSize > UIFont.preferredFontMaximumSize(.footnote) {
            let fontSize = UIFont.preferredFontMaximumSize(.footnote)
            let weight = UIFont.preferredFontDefaultWeight(.footnote)
            font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        }
        label.font = font
        label.textColor = RCVColor.get(.neutralF05)
        label.accessibilityIdentifier = "devicesLabel"
        label.backgroundColor = .clear//RCVColor.get(.neutralB01)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }
    
    private func initSubView() {
        backgroundColor = RCVColor.get(.neutralB05)
        contentView.backgroundColor = RCVColor.get(.neutralB05)
        
        separatorInset = UIEdgeInsets(top: 0, left: ParticipantLayout.margin * 2.0 + ParticipantLayout.avatarWidth, bottom: 0, right: 0)
        
        avatarView = RCVMeetingAvatarView()
        avatarView.backgroundColor = .clear
        contentView.addSubview(avatarView)
        avatarView.isAccessibilityElement = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12.0),
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ParticipantLayout.margin),
            avatarView.widthAnchor.constraint(equalToConstant: ParticipantLayout.avatarWidth),
            avatarView.heightAnchor.constraint(equalToConstant: ParticipantLayout.avatarWidth),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
        
        contentView.addSubview(hostIndicatorImageView)
        hostIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
        hostIndicatorImageView.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 0).isActive = true
        hostIndicatorImageView.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 4).isActive = true
        hostIndicatorImageView.widthAnchor.constraint(equalToConstant: ParticipantLayout.hostIconHeight).isActive = true
        hostIndicatorImageView.heightAnchor.constraint(equalToConstant: ParticipantLayout.hostIconHeight).isActive = true

        let titleStackView = UIStackView(frame: CGRect.zero)
        titleStackView.axis = .horizontal
        titleStackView.spacing = 10

        titleStackView.addArrangedSubview(titleLabel)
        titleLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)
        stautsContentView.setContentCompressionResistancePriority(.required, for: NSLayoutConstraint.Axis.horizontal)
        devicesLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let labelStack = UIStackView(arrangedSubviews: [titleStackView, stautsContentView, devicesLabel])
        labelStack.axis = .vertical
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelStack)
        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            labelStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: ParticipantLayout.margin),
            labelStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            labelStack.heightAnchor.constraint(greaterThanOrEqualToConstant: ParticipantLayout.avatarWidth),
        ])

        selectionStyle = .none
    }
    
    func configCell(participant: RcvIParticipant) {
        let width = Int32(ParticipantLayout.avatarWidth * UIScreen.main.scale)
        avatarView.nameLabel.isHidden = false
        let avatarName = participant.getInitialsAvatarName()
        let headshotColor = participant.getHeadshotColor()
        avatarView.setAvatarImage(name: avatarName, colorType: headshotColor)

        // isHost
        if participant.isHost() {
            titleLabel.textColor = RCVColor.get(.labelBlue02)
            hostIndicatorImageView.isHidden = false
        } else if participant.isModerator() {
            titleLabel.textColor = RCVColor.get(.neutralB01)
            hostIndicatorImageView.isHidden = false
        } else {
            titleLabel.textColor = RCVColor.get(.neutralB01)
            hostIndicatorImageView.isHidden = true
        }
        
        let contentLabel = stautsContentView.contentLabel
        
        contentLabel.text = "Disconnected"
        
        if participant.getMediaReconnection() {
            stautsContentView.setConetentLable(isHidden: false)
            contentLabel.text = "Reconnecting..."
        }

        if participant.isPinned() {
            stautsContentView.setConetentLable(isHidden: false)
            if let text = contentLabel.text, text.count > 0 {
                contentLabel.text = "Pinned" + ", " + text
            } else {
                contentLabel.text = "Pinned"
            }
        }
        
        // active device count
        let activeDeviceCount = participant.getActiveDeviceCount()

        devicesLabel.isHidden = activeDeviceCount <= 1
        devicesLabel.text = String(activeDeviceCount) + " devices"

        //title
        titleLabel.attributedText = nil
        titleLabel.text = getParticipantShowName(participant: participant)
    }
    
    private func getParticipantShowName(participant: RcvIParticipant)-> String {
        let userName = participant.displayName()
        
        if participant.isHost() && participant.isMe() {
            return userName + " (Host, me)"
        } else if participant.isHost() {
            return userName + " (Host)"
        } else if participant.isMe() {
            return userName + " (me)"
        } else {
            return userName
        }
    }
}
//class RCVParticipantsNotconnectCell: UITableViewCell {
//    private let kDefaultMargin: CGFloat = 14
//    private let kDefaultAvatarSize: CGFloat = 46
//    private let kTitleSpacing: CGFloat = 8
//    static let hostIconHeight: CGFloat = 16
//
//    private var avatarView: RCVMeetingAvatarView!
//
//    var hostIndicatorImageView: UIView {
//        let contentView = UIView()
//        contentView.frame = CGRect(x: 0, y: 0, width: RCVParticipantsNotconnectCell.hostIconHeight, height: RCVParticipantsNotconnectCell.hostIconHeight)
//        contentView.backgroundColor = .clear
//        contentView.layer.cornerRadius = RCVParticipantsNotconnectCell.hostIconHeight / 2.0
//
//        let innerHeight = RCVParticipantsNotconnectCell.hostIconHeight - 4.0
//        let innerLayer = CALayer()
//        innerLayer.frame = CGRect(x: 2, y: 2, width: innerHeight, height: innerHeight)
//        innerLayer.backgroundColor = RCVColor.get(.warningF02).cgColor
//        innerLayer.cornerRadius = innerHeight / 2.0
//        contentView.layer.addSublayer(innerLayer)
//
//        let label = UILabel(frame: contentView.bounds)
//        //label.setFontAwesome(.RCVHostIndicator, fontSize: 10)
//        label.textAlignment = .center
//        label.textColor = RCVColor.get(.neutralF01)
//        contentView.addSubview(label)
//        return contentView
//    }
//
//    var titleLabel: UILabel = {
//        let titleLabel = UILabel()
//        titleLabel.textAlignment = NSTextAlignment.left
//
//        var font = UIFont.preferredFont(forTextStyle: .callout)
//        if font.pointSize > UIFont.preferredFontMaximumSize(.callout) {
//            let fontSize = UIFont.preferredFontMaximumSize(.callout)
//            let weight = UIFont.preferredFontDefaultWeight(.callout)
//            font = UIFont.systemFont(ofSize: fontSize, weight: weight)
//        }
//        titleLabel.font = font
//        titleLabel.adjustsFontForContentSizeCategory = true
//        titleLabel.accessibilityIdentifier = "statusTitleLabel"
//        titleLabel.backgroundColor = .clear
//        titleLabel.numberOfLines = 0
//        titleLabel.lineBreakMode = .byWordWrapping
//        return titleLabel
//    }()
//
//    var descLabel: UILabel = {
//        let descLabel = UILabel()
//        descLabel.textAlignment = .left
//        descLabel.textColor = RCVColor.get(.neutralF05)
//        var font = UIFont.preferredFont(forTextStyle: .subheadline)
//        if font.pointSize > UIFont.preferredFontMaximumSize(.subheadline) {
//            let fontSize = UIFont.preferredFontMaximumSize(.subheadline)
//            let weight = UIFont.preferredFontDefaultWeight(.subheadline)
//            font = UIFont.systemFont(ofSize: fontSize, weight: weight)
//        }
//        descLabel.font = font
//        descLabel.accessibilityIdentifier = "statusDescLabel"
//        return descLabel
//    }()
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        initSubView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        initSubView()
//    }
//
//    private func initSubView() {
//        backgroundColor = .clear
//        contentView.backgroundColor = .clear
//
//        separatorInset = UIEdgeInsets(top: 0, left: kDefaultMargin + kDefaultAvatarSize + kDefaultMargin, bottom: 0, right: 0)
//        avatarView = RCVMeetingAvatarView()
//        avatarView.backgroundColor = .clear
//        contentView.addSubview(avatarView)
//        avatarView.translatesAutoresizingMaskIntoConstraints = false
//        avatarView.isAccessibilityElement = true
//        NSLayoutConstraint.activate([
//            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kDefaultMargin),
//            avatarView.widthAnchor.constraint(equalToConstant: kDefaultAvatarSize),
//            avatarView.heightAnchor.constraint(equalToConstant: kDefaultAvatarSize),
//            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//        ])
//
//        contentView.addSubview(hostIndicatorImageView)
//        hostIndicatorImageView.translatesAutoresizingMaskIntoConstraints = false
//        hostIndicatorImageView.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 0).isActive = true
//        hostIndicatorImageView.trailingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 4).isActive = true
//        hostIndicatorImageView.widthAnchor.constraint(equalToConstant: RCVParticipantsNotconnectCell.hostIconHeight).isActive = true
//        hostIndicatorImageView.heightAnchor.constraint(equalToConstant: RCVParticipantsNotconnectCell.hostIconHeight).isActive = true
//
//        contentView.addSubview(titleLabel)
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: kDefaultMargin).isActive = true
//        titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: kDefaultMargin).isActive = true
//        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -kTitleSpacing).isActive = true
//
//        contentView.addSubview(descLabel)
//        descLabel.translatesAutoresizingMaskIntoConstraints = false
//        descLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: kDefaultMargin).isActive = true
//        descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2).isActive = true
//        descLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -kDefaultMargin).isActive = true
//
//        selectionStyle = .none
//    }
//
//    func configCell(participant: RcvIParticipant){
//        descLabel.text = "This Status copy need to be update"
//        let width = Int32(kDefaultAvatarSize * UIScreen.main.scale)
//        avatarView.nameLabel.isHidden = false
//        let avatarName = participant.getInitialsAvatarName()
//        let headshotColor = participant.getHeadshotColor()
//        avatarView.setAvatarImage(name: avatarName, colorType: headshotColor)
//        avatarView.accessibilityLabel = "View" + participant.displayName() + "profile"
//        avatarView.accessibilityTraits = .button
//
//        // isHost
//        if participant.isHost() {
//            titleLabel.textColor = RCVColor.get(.interactiveF01)
//            hostIndicatorImageView.isHidden = false
//        } else if participant.isModerator() {
//            titleLabel.textColor = RCVColor.get(.neutralF06)
//            hostIndicatorImageView.isHidden = false
//        } else {
//            titleLabel.textColor = RCVColor.get(.neutralF06)
//            hostIndicatorImageView.isHidden = true
//        }
//
//        //title
//        titleLabel.text = participant.displayName()
//    }
//}
