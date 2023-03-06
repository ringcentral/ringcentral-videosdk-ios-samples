//
//  RCVMeetingToolbar.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

enum BubbleDirection {
    case up
    case down
}

protocol RCVMeetingToolbarDelegate: NSObjectProtocol {
    func didSelectToolbarItem(_ item: RCVToolBarItem?)
}

class RCVMeetingToolbar: UIView {
    public weak var delegate: RCVMeetingToolbarDelegate?
    
    private var bubbleViewCenterXAnchor: NSLayoutConstraint?
    private var bubbleViewTopAnchor: NSLayoutConstraint?
    private var bubbleViewBottomAnchor: NSLayoutConstraint?
    private var meetingActionBubbleViewCenterXAnchor: NSLayoutConstraint?
    private var meetingActionBubbleViewTopAnchor: NSLayoutConstraint?
    private var meetingActionBubbleViewBottomAnchor: NSLayoutConstraint?

    public var toolbarItems: [RCVToolBarItem]? {
        didSet {
            creatSubviews()
        }
    }
    
    public var microphoneButton: RCVMicrophoneButton?
    public var audioChannelButton: RCVToolBarButton?
    public var participantsButton: RCVToolBarButton?
    
    private func creatSubviews() {
        guard let toolbarItems = toolbarItems else {
            return
        }
        
        microphoneButton = nil
        audioChannelButton = nil
        participantsButton = nil
        horizontalStackView.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        
        if toolbarItems.count == 0 {
            return
        }
        
        for item in toolbarItems {
            let tabButton: RCVToolBarButton
            switch item.itemType {
            case .mute:
                tabButton = RCVMicrophoneButton()
            case .participant:
                tabButton = RCVParticipantsButton()
            default:
                tabButton = RCVToolBarButton()
            }
            
            horizontalStackView.addArrangedSubview(tabButton)
            
            switch item.itemType {
            case .mute:
                microphoneButton = tabButton as? RCVMicrophoneButton
            case .audioChannel:
                audioChannelButton = tabButton
            case .participant:
                participantsButton = tabButton
            default:
                break
            }
            
            tabButton.space = 0
            tabButton.textLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFont.Weight.regular)
            tabButton.inset = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            
            tabButton.viewModel = item
            tabButton.addTarget(self, action: #selector(RCVMeetingToolbar.tapAction(_:)), for: .touchUpInside)
        }
    }
    
    public var bubbleDirection: BubbleDirection = .down {
        didSet {
            switch bubbleDirection {
            case .up:
                bubbleViewBottomAnchor?.isActive = false
                bubbleViewTopAnchor?.isActive = true
                meetingActionBubbleViewBottomAnchor?.isActive = false
                meetingActionBubbleViewTopAnchor?.isActive = true
            default:
                bubbleViewTopAnchor?.isActive = false
                bubbleViewBottomAnchor?.isActive = true
                meetingActionBubbleViewTopAnchor?.isActive = false
                meetingActionBubbleViewBottomAnchor?.isActive = true
            }
        }
    }
    
    private let visualEffectView: UIVisualEffectView = {
        let effectiveView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return effectiveView
    }()
    
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        return stackView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    private func configureUI() {
        addSubview(visualEffectView)
        addSubview(horizontalStackView)
        
        visualEffectView.makeConstraintsToBindToSuperview()
        
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        horizontalStackView.topAnchor.constraint(equalTo: safeTopAnchor).isActive = true
        horizontalStackView.bottomAnchor.constraint(equalTo: safeBottomAnchor).isActive = true
        horizontalStackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        horizontalStackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        horizontalStackView.accessibilityIdentifier = "MeetingBottomButtonStackView"
    }
    
    public func reloadToolItems(item: RCVToolBarItem?) {
        for button in horizontalStackView.arrangedSubviews {
            if let badgeTabButton = button as? RCVToolBarButton,
                badgeTabButton.viewModel?.itemType == item?.itemType {
                badgeTabButton.update()
                break
            }
        }
    }
    
    @objc private func tapAction(_ button: RCVToolBarButton) {
        delegate?.didSelectToolbarItem(button.viewModel)
    }
}
