//
//  RCVParticipantWaitingRoomCell.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

class RCVParticipantWaitingRoomCell: UITableViewCell {
    private var avatarView: RCVMeetingAvatarView!
    weak var actionDelegate: RCVParticipantCellDelegate?
    var audioButtonWidthConstraint: NSLayoutConstraint?
    
    private let moreButton: ParticipantStatusButton = {
        let button = ParticipantStatusButton(type: .custom)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        button.accessibilityIdentifier = "moreButton"
        button.setTitle("More", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        let img: UIImage = button.imageWithColor(RCVColor.get(.labelBlue02).rc_resolvedColor(with: button.traitCollection))!
        button.setBackgroundImage(img, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityTraits = .button
        button.accessibilityLabel = "More"
        button.isAccessibilityElement = true
        return button
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }
    
    private func initSubView() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
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
        
        contentView.addSubview(moreButton)
        moreButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        moreButton.widthAnchor.constraint(equalToConstant: 84).isActive = true
        
        moreButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4).isActive = true
        moreButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
//        moreButton.setContentCompressionResistancePriority(.required, for: .vertical)
//        moreButton.setContentHuggingPriority(.required, for: .horizontal)
//        moreButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        let titleStackView = UIStackView(frame: CGRect.zero)
        titleStackView.axis = .horizontal
        titleStackView.spacing = 10

        titleStackView.addArrangedSubview(titleLabel)
        titleLabel.setContentHuggingPriority(UILayoutPriority.required, for: NSLayoutConstraint.Axis.horizontal)

        let labelStack = UIStackView(arrangedSubviews: [titleStackView])
        labelStack.axis = .vertical
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelStack)
        NSLayoutConstraint.activate([
            labelStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 8),
            labelStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelStack.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: ParticipantLayout.margin),
            labelStack.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -2),
            labelStack.heightAnchor.constraint(greaterThanOrEqualToConstant: ParticipantLayout.avatarWidth),
        ])

        selectionStyle = .none
        
        moreButton.addTarget(self, action: #selector(moreButtonAction(sender:)), for: .touchUpInside)
    }
    
    @objc func moreButtonAction(sender: UIButton) {
        self.actionDelegate?.didTapInWaitRoomMoreAction(cell: self)
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
        } else if participant.isModerator() {
            titleLabel.textColor = RCVColor.get(.neutralB01)
        } else {
            titleLabel.textColor = RCVColor.get(.neutralB01)
        }

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
