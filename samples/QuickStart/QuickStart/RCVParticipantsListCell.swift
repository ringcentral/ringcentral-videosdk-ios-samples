//
//  RCVParticipantsListCell.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk


class MicIndicatorView: UIView {
    var normalIcon = UIImage()
    var speakingIcon = UIImage()
    var mutedIcon = UIImage()
    var disconnectIcon = UIImage()
    let indicator = UIImageView(image: nil)
    let key = "com.animationKey"

    private struct Icon {
        static let pstnUnmute = RCVColor.image(named: "icPstnUnmuted")
        static let pstnSpeaking = RCVColor.image(named: "icPstnUnmuted")//?.imageApplyColor(RCColor.get(.successF02))
        static let pstnMute = RCVColor.image(named: "icPstnMuted")!
        static let internetUnmute = RCVColor.image(named: "icUnmutedCopy")!
        static let internetSpeaking = RCVColor.image(named: "icUnmutedCopy")//?.imageApplyColor(RCColor.get(.successF02))
        static let internetMute = RCVColor.image(named: "icMutedCopy")!
        static let disconnect = RCVColor.image(named: "icNoaudioCopy")!
    }

    enum AudioStatus {
        case internet
        case pstn
        case disconnect
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    fileprivate func initialize() {
        indicator.contentMode = .scaleAspectFit
        addSubview(indicator)
        indicator.makeConstraintsToBindToSuperview()
    }

    public var iconSize: CGFloat = 14 {
        didSet { updateIcons() }
    }

    public var isSpeaking: Bool = false {
        didSet { update() }
    }

    public var isMuted: Bool = false {
        didSet { update() }
    }

    public var audioStatus: AudioStatus = .disconnect {
        didSet { updateIcons() }
    }

    private func updateIcons() {
        switch audioStatus {
        case .pstn:
            normalIcon = Icon.pstnUnmute!
            speakingIcon = Icon.pstnSpeaking ?? normalIcon
            mutedIcon = Icon.pstnMute
        case .internet:
            normalIcon = Icon.internetUnmute
            speakingIcon = Icon.internetSpeaking ?? normalIcon
            mutedIcon = Icon.internetMute
        case .disconnect:
            disconnectIcon = Icon.disconnect
        }
    }

    private func createAnimation() -> CAAnimation {
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.duration = 0.8
        animation.values = [normalIcon, speakingIcon, normalIcon].compactMap { $0.cgImage }
        let timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.1, 0.25, 1.0)
        animation.timingFunctions = [timingFunction, timingFunction]
        animation.keyTimes = [NSNumber(value: 0.0), NSNumber(value: 0.25), NSNumber(value: 1.0)]
        animation.repeatCount = Float.infinity
        return animation
    }

    func update() {
        guard audioStatus != .disconnect else {
            indicator.layer.removeAnimation(forKey: key)
            indicator.image = disconnectIcon
            return
        }
        if isMuted {
            indicator.layer.removeAnimation(forKey: key)
            indicator.image = mutedIcon
        } else {
            if isSpeaking {
                indicator.layer.add(createAnimation(), forKey: key)
            } else {
                indicator.layer.removeAnimation(forKey: key)
                indicator.image = normalIcon
            }
        }
        invalidateIntrinsicContentSize()
    }

    func getAccessibilityLabel() -> String {
        switch audioStatus {
        case .internet:
            if isMuted {
                return "Muted"
            } else {
                return "Unmuted"
            }
        case .disconnect:
            return "Disconnected to audio"
        case .pstn:
            if isMuted {
                return "Phone muted"
            } else {
                return "Phone unmuted"
            }
        }
    }

    func getAccessibilityIdentifier() -> String {
        switch audioStatus {
        case .internet:
            if isMuted {
                return "Muted"
            } else {
                return isSpeaking ? "Unmuted, isSpeaking" : "Unmuted"
            }
        case .disconnect:
            return "Disconnected to audio"
        case .pstn:
            if isMuted {
                return "Phone muted"
            } else {
                return isSpeaking ? "Phone unmuted, isSpeaking" : "Phone unmuted"
            }
        }
    }
}

protocol RCVParticipantCellDelegate: AnyObject {
    func didTapAudioStatusAction(cell: UITableViewCell)
    func didTapVideoStatusAction(cell: UITableViewCell)
    func didTapInWaitRoomMoreAction(cell: UITableViewCell)
    func didTapParticipantMoreAction(cell: UITableViewCell)
}

class MarginLabel: UILabel {
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.width += contentInset.left + contentInset.right
        size.height += contentInset.top + contentInset.bottom
        if let width = self.superview?.frame.size.width, width > 0, size.width > width * 0.75 {
            size.width = width * 0.75
        }
        return size
    }

    override func draw(_ rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInset))
    }
}

enum NQIQuality: String {
    case disconnected
    case poor
    case medium
    case good = "goog"
    case unknown
    case stable
}

enum NQIIconType {
    case me
    case participants
    case galleryView
    case detailScreen
}


extension NQIQuality {
    func getAccessibilityValue(_ type: NQIIconType) -> String? {
        switch self {
        case .poor:
            return "Poor connection"
        case .medium:
            return "Weak connection"
        case .disconnected:
            return "No connection"
        case .good:
            return "Good connection"
        case .stable:
            return "Good connection"
        default:
            return nil
        }
    }

    init(participant: RcvIParticipant) {
        let value = participant.getNqiStatus()
        switch value {
        case RcvENqiStatus.disconnected:
            self = .disconnected
        case RcvENqiStatus.poor:
            self = .poor
        case RcvENqiStatus.medium:
            self = .medium
        case RcvENqiStatus.good:
            self = .good
        case RcvENqiStatus.unknown:
            self = .unknown
        case RcvENqiStatus.stable:
            self = .stable
        default:
            self = .unknown
        }
    }

    func getNQIIconImage(_ type: NQIIconType) -> UIImage? {
        switch self {
        case .poor:
            if type == .galleryView {
                return RCVColor.image(named: "img_indicator_poor")
            } else if type == .participants || type == .detailScreen {
                return RCVColor.image(named: "img_participants_poor")
            } else {
                return RCVColor.image(named: "img_self_poor")
            }
        case .medium:
            if type == .galleryView {
                return RCVColor.image(named: "img_indicator_medium")
            } else if type == .participants || type == .detailScreen {
                return RCVColor.image(named: "img_participants_medium")
            } else {
                return RCVColor.image(named: "img_self_medium")
            }
        case .disconnected:
            if type == .galleryView {
                return RCVColor.image(named: "img_indicator_none")
            } else if type == .participants || type == .detailScreen {
                return RCVColor.image(named: "img_participants_none")
            } else {
                return RCVColor.image(named: "img_self_none")
            }
        case .good:
            if type == .galleryView {
                return RCVColor.image(named: "img_indicator_good")
            } else if type == .participants || type == .detailScreen {
                return RCVColor.image(named: "img_participants_good")
            } else {
                return RCVColor.image(named: "img_self_good")
            }
        case .stable:
            if type == .me {
                return RCVColor.image(named: "img_self_good")
            } else if type == .participants || type == .detailScreen {
                return RCVColor.image(named: "img_participants_good")
            } else {
                return RCVColor.image(named: "img_self_good")
            }
        case .unknown:
            if type == .galleryView {
                return RCVColor.image(named: "img_indicator_none")
            } else if type == .participants || type == .detailScreen {
                return RCVColor.image(named: "img_participants_none")
            } else {
                return RCVColor.image(named: "img_self_none")
            }
        }
    }
}


class InfoContainer: UIView {
    var micIndicator: MicIndicatorView = MicIndicatorView()
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
        return stackView
    }()

    var signalImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    var quality: NQIQuality? {
        didSet { update() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configurateSubViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configurateSubViews()
    }

    var nameLabel: UILabel = UILabel()

    func configureNameLabel() {
        nameLabel.textColor = RCVColor.get(.neutralF01)
    }

    func configurateSubViews() {
        backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        configureNameLabel()
        udpateStackViewSubViews()

        micIndicator.accessibilityIdentifier = "micIndicator"
        micIndicator.isAccessibilityElement = true
        signalImageView.accessibilityIdentifier = "signalImageView"
        signalImageView.isAccessibilityElement = true
    }

    func udpateStackViewSubViews() {
        stackView.addArrangedSubview(signalImageView)
        signalImageView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(micIndicator)
        micIndicator.translatesAutoresizingMaskIntoConstraints = false
        micIndicator.update()
        
        stackView.addArrangedSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 2.0).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -2.0).isActive = true
        stackView.spacing = 2.0

        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        nameLabel.setContentHuggingPriority(.required, for: .vertical)
        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        NSLayoutConstraint.activate([
            signalImageView.heightAnchor.constraint(equalToConstant: 12.0),
            signalImageView.widthAnchor.constraint(equalToConstant: 14.0),
        ])
    }
    
    func update() {
        if let quality = self.quality {
            if let image = quality.getNQIIconImage(.galleryView) {
                signalImageView.image = image
                signalImageView.isHidden = false
            } else {
                signalImageView.image = nil
                signalImageView.isHidden = true
            }
            signalImageView.accessibilityValue = quality.rawValue
        } else {
            signalImageView.image = nil
            signalImageView.isHidden = true
        }
        
    }
    
    func update(with participant: RcvIParticipant) {
        guard (participant.isAllowUmuteAudio() == true) || participant.isMe() else {
            return
        }
        if participant.isPstn() {
            micIndicator.audioStatus = .pstn
        } else {
            if participant.inAudioStreamActivity() == .inactive {
                micIndicator.audioStatus = .disconnect
            } else {
                micIndicator.audioStatus = .internet
            }
        }
        var isMuted = participant.audioServerMute() || participant.audioLocalMute()
        if participant.isMe() {
            let audioController = RCVMeetingDataSource.getAudioController()
            isMuted = audioController!.isMuted()
        }

        if isMuted {
            micIndicator.isMuted = true
        } else {
            micIndicator.isMuted = false
            micIndicator.isSpeaking = participant.isSpeaking()
        }
    }
}


class SpeakerView: UIView {
    @IBOutlet var label: UILabel!
    @IBOutlet var onHoldIconLabel: UILabel!
    lazy var nameLabel: MarginLabel = {
        let label = MarginLabel()
        return label
    }()
    @IBOutlet var avatarView: RCVMeetingAvatarView!
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        return view
    }()
    //weak var delegate: SpeakerViewDelegate?
    var videoView: UIView = {
        let view = UIView()
        return view
    }()
    
    var accessibilityContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isAccessibilityElement = true
        view.accessibilityTraits = .button
        return view
    }()

    var participantModel: RcvIParticipant?
    var debugEnabled: Bool = false
    var hasReceivedFirstFrame: Bool = true
    var autoUpdateVideoView = true
    var accessibilityActivateAction: (() -> Bool)?
    //var reactionActionBlock: ((UIView, RcvIParticipant, MeetingReactionsActionType, CGRect) -> Void)?

    var externalReconnectingImage: UIImage?

    var allowShowPin = false
    var infoContainerLeftContraint: NSLayoutConstraint?
    var infoContainer: InfoContainer = {
        let container = InfoContainer()
        return container
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func accessibilityActivate() -> Bool {
        return accessibilityActivateAction?() == true
    }

    func configSubview() {
        avatarView = RCVMeetingAvatarView()
        avatarView.backgroundColor = .clear
        avatarView.accessibilityIdentifier = "avatarView"
        addSubview(avatarView)
        avatarView.isAccessibilityElement = true
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.widthAnchor.constraint(equalToConstant: 90),
            avatarView.heightAnchor.constraint(equalToConstant: 90),
            avatarView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            avatarView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        nameLabel.textColor = RCVColor.get(.neutralF01)
        nameLabel.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)

        addSubview(infoContainer)
        infoContainer.translatesAutoresizingMaskIntoConstraints = false
        infoContainerLeftContraint = infoContainer.leftAnchor.constraint(equalTo: safeLeftAnchor, constant: 0)
        infoContainerLeftContraint?.isActive = true
        NSLayoutConstraint.activate([
            infoContainer.bottomAnchor.constraint(equalTo: safeBottomAnchor, constant: 0),
            infoContainer.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8),
        ])
        stackView.spacing = 10
        addVideoView(videoView)
    }

    func addVideoView(_ newVideoView: UIView) {
        videoView.removeFromSuperview()
        addSubview(newVideoView)
        newVideoView.translatesAutoresizingMaskIntoConstraints = false
        newVideoView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        newVideoView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        newVideoView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        newVideoView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        videoView = newVideoView
        videoView.makeConstraintsToBindToSuperview()
        bringSubviewToFront(infoContainer)
    }

    func prepareForReuse() {
        videoView.isHidden = true
        nameLabel.text = nil
        infoContainer.nameLabel.text = nil
        infoContainer.isHidden = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        isAccessibilityElement = false
        accessibilityContentView.isAccessibilityElement = true
        accessibilityIdentifier = "SpeakerView"
    }

    func infoViewLeftContraintUpdate(to: CGFloat, animated: Bool) {
        infoContainerLeftContraint?.constant = to
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.layoutIfNeeded()
        }
    }

    func update(with participant: RcvIParticipant) {
        participantModel = participant

        avatarView.nameLabel.isHidden = false
        let avatarName = participant.getInitialsAvatarName()
        let headshotColor = participant.getHeadshotColor()
        avatarView.setAvatarImage(name: avatarName, colorType: headshotColor)
        
        if(participant.isVideoOn()){
            videoView.isHidden = false
        }
        else{
            videoView.isHidden = true
        }
        
        let name: String
        if participant.isMe() {
            name = participant.displayName() + " (me)"
        } else {
            name = participant.displayName()
        }
        nameLabel.text = name
        infoContainer.nameLabel.text = name
        
        switch participant.status() {
        case .ACTIVE:
            infoContainer.isHidden = false
            nameLabel.isHidden = true

            let quality = NQIQuality(participant: participant)
            infoContainer.quality = quality
            infoContainer.update(with: participant)

        case .RINGING:
            infoContainer.isHidden = true
            nameLabel.isHidden = false
        default:
            infoContainer.isHidden = true
            nameLabel.isHidden = false
        }
    }

    func resetFirstFrame() {
        hasReceivedFirstFrame = false
    }
}


class RCVParticipantsListCell: UICollectionViewCell {
    public static let cellIndentifier = "RCVParticipantsListCell"
    public let containerView = UIView()
    lazy var speakerView : SpeakerView = {
        let view = SpeakerView()
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup() {
        backgroundColor = UIColor.clear
        
        contentView.makeConstraintsToBindToSuperview()
        contentView.addSubview(containerView)
        containerView.makeConstraintsToBindToSuperview()

        setupSpeakView()
    }
    
    func setupSpeakView() {
        speakerView.layer.borderWidth = 1
        speakerView.layer.borderColor = CGColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        containerView.addSubview(speakerView)
        speakerView.makeConstraintsToBindToSuperview()
    }
    
    func update(user : RcvIParticipant) {
        speakerView.update(with: user)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func getVideoView() -> UIView {
        return speakerView.videoView
    }
}

class ParticipantWaitingRoomAdmitAllHeader: UITableViewHeaderFooterView {
    
}
