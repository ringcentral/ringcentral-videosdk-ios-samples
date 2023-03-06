//
//  RCVParticipantCell.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 2/13/23.
//
import UIKit
import rcvsdk
struct ParticipantLayout {
    static let margin: CGFloat = 14.0
    static let avatarWidth: CGFloat = 46.0
    static let titleSpace: CGFloat = 8.0
    static let hostIconHeight: CGFloat = 16.0
    static let buttonFontSize: CGFloat = 32.0
}

class ParticipantCell: UITableViewCell {
    weak var actionDelegate: RCVParticipantCellDelegate?
    private var avatarView: RCVMeetingAvatarView!
    private var stackView: UIStackView!
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
    
    let audioStatusButton: ParticipantStatusButton = {
        let button = ParticipantStatusButton(type: .custom)
        button.iconLeftPadding = 10
        button.contentMode = .center
        button.imageView?.contentMode = .center
        button.accessibilityIdentifier = "audioStatusButton"
        button.isAccessibilityElement = true
        return button
    }()
    
    let videoStatusButton: ParticipantStatusButton = {
        let button = ParticipantStatusButton(type: .custom)
        button.contentMode = .center
        button.imageView?.contentMode = .center
        button.accessibilityIdentifier = "videoStatusButton"
        button.isAccessibilityElement = true
        return button
    }()
    
    let moreOperationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.contentMode = .center
        button.imageView?.contentMode = .center
        button.backgroundColor = .clear
        button.setMeetingIcon(.GFIMoreAction, fontSize: 20.0, textColor: RCVColor.get(.neutralF05), for: .normal)
        button.accessibilityIdentifier = "moreOperationButton"
        button.accessibilityLabel = "More"
        button.isAccessibilityElement = true
        return button
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

        stackView = UIStackView(frame: CGRect.zero)
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        contentView.addSubview(stackView)

        stackView.addArrangedSubview(statusImageView)
        statusImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        statusImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true

        stackView.addArrangedSubview(audioStatusButton)
        audioButtonWidthConstraint = audioStatusButton.widthAnchor.constraint(equalToConstant: 44)
        audioButtonWidthConstraint?.isActive = true
        audioStatusButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        audioStatusButton.layer.contentsGravity = CALayerContentsGravity.resizeAspect
        audioStatusButton.addTarget(self, action: #selector(audioButtonAction(sender:)), for: .touchUpInside)

        stackView.addArrangedSubview(videoStatusButton)
        videoStatusButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        videoStatusButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        videoStatusButton.addTarget(self, action: #selector(videoButtonAction(sender:)), for: .touchUpInside)

        stackView.addArrangedSubview(moreOperationButton)
        moreOperationButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        moreOperationButton.addTarget(self, action: #selector(moreButtonAction(sender:)), for: .touchUpInside)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -4).isActive = true
        stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

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
            labelStack.trailingAnchor.constraint(equalTo: stackView.leadingAnchor),
            labelStack.heightAnchor.constraint(greaterThanOrEqualToConstant: ParticipantLayout.avatarWidth),
        ])

        selectionStyle = .none
    }
    
    @objc private func audioButtonAction(sender: UIButton) {
        actionDelegate?.didTapAudioStatusAction(cell: self)
    }
    
    @objc private func videoButtonAction(sender: UIButton) {
        actionDelegate?.didTapVideoStatusAction(cell: self)
    }
    
    @objc func moreButtonAction(sender: UIButton) {
        actionDelegate?.didTapParticipantMoreAction(cell: self)
    }
    
    private func getNQIIconImage(participant: RcvIParticipant) ->UIImage? {
        let nqiStatus = participant.getNqiStatus()
        switch nqiStatus {
        case .good:
            return RCVColor.image(named: "img_participants_good")
        case .medium:
            return RCVColor.image(named: "img_participants_medium")
        case .poor:
            return RCVColor.image(named: "img_participants_poor")
        case .disconnected:
            return RCVColor.image(named: "img_participants_none")
        case .stable:
            return RCVColor.image(named: "img_participants_good")
        case .unknown:
            if participant.isMe() {
                return RCVColor.image(named: "img_self_good")
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    private func updateQuality(participant: RcvIParticipant) {
        if let image = getNQIIconImage(participant: participant) {
                statusImageView.image = image
                statusImageView.isHidden = false
            } else {
                statusImageView.image = nil
                statusImageView.isHidden = true
            }
    }
    
    func configCell(participant: RcvIParticipant) {
        updateQuality(participant: participant)
        //let width = Int32(ParticipantLayout.avatarWidth * UIScreen.main.scale)
        avatarView.nameLabel.isHidden = false
        let avatarName = participant.getInitialsAvatarName()
        let headshotColor = participant.getHeadshotColor()
        avatarView.setAvatarImage(name: avatarName, colorType: headshotColor)
        
        if let videoIcon = videoIcon(participant: participant) {
            let state: UIControl.State = videoIcon.isEnabled ? .normal : .disabled
            videoStatusButton.isHidden = false
            videoStatusButton.setImage(videoIcon.image, for: state)
            
            let videoController = RCVMeetingDataSource.getVideoController()
            videoStatusButton.accessibilityLabel = videoController!.isMuted() ? "Turn on video" : "Turn off video"
            videoStatusButton.isEnabled = videoIcon.isEnabled
        } else {
            // PSTN
            videoStatusButton.isHidden = true
        }
        
        // audio status
        if let audioIcon = audioIcon(participant: participant) {
            let state: UIControl.State = audioIcon.isEnabled ? .normal : .disabled
            audioStatusButton.layer.removeAllAnimations()
            audioStatusButton.isHidden = false
            audioButtonWidthConstraint?.constant = 44
            audioStatusButton.setImage(audioIcon.image, for: state)
            audioStatusButton.isEnabled = audioIcon.isEnabled
        } else {
            audioStatusButton.isHidden = true
            audioButtonWidthConstraint?.constant = 0
        }
        
    
        audioStatusButton.isLock = !participant.isAllowUmuteAudio()
        videoStatusButton.isLock = !participant.isAllowUmuteVideo()

        let audioController = RCVMeetingDataSource.getAudioController()
        audioStatusButton.accessibilityLabel = audioController!.isMuted() ? "Unmute" : "Mute"

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
        
        /// Config Hide More Button
        configHideMoreButton(participant: participant)
        
        let contentLabel = stautsContentView.contentLabel
        
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
    
    private func configHideMoreButton(participant: RcvIParticipant) {
        if participant.status() == .ACTIVE {
            moreOperationButton.isHidden = participant.isMe()
        } else {
            /// In waiting room
            moreOperationButton.isHidden = participant.isHost() || participant.isMe()
        }
    }
    
    private func videoIcon(participant: RcvIParticipant) -> StatusIcon? {
        let image: UIImage?
        if participant.isMe() || participant.isHost() || participant.isModerator() {
            if participant.isMe(), RCVMeetingDataSource.isSharingCamera() {
                image = StatusIcon.videoOffDisabled
                return StatusIcon(image: image, isEnabled: false)
            } else {
                let mute = participant.videoLocalMute() || participant.videoServerMute()
                image = mute ? StatusIcon.videoOff : StatusIcon.videoOn
                return StatusIcon(image: image, isEnabled: true)
            }
        } else {
            let mute = participant.videoLocalMute() || participant.videoServerMute()
            image = mute ? StatusIcon.videoOffDisabled : StatusIcon.videoOnDisabled
            return StatusIcon(image: image, isEnabled: false)
        }
    }
    
    private func audioIcon(participant: RcvIParticipant) -> StatusIcon? {
        let image: UIImage?
        if participant.isMe() || participant.isHost() || participant.isModerator() {
            let mute = participant.audioLocalMute() || participant.audioServerMute()
            image = mute ? StatusIcon.audioOff : StatusIcon.audioOn
            return StatusIcon(image: image, isEnabled: true)
        } else {
            let mute = participant.audioLocalMute() || participant.audioServerMute()
            image = mute ? StatusIcon.audioOffDisabled : StatusIcon.audioOnDisabled
            return StatusIcon(image: image, isEnabled: false)
        }
    }
}
