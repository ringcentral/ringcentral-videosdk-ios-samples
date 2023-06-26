//
//  RCVMeetingDetailInfoView.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

protocol RCVMeetingDetailInfoViewProtocol: RCVMeetingPopupBaseView {
    func setMeetingDuration(duration: String)
}

class RCVMeetingDetailInfoView: RCVMeetingPopupBaseView, RCVMeetingDetailInfoViewProtocol {
    private let titleLabel = UILabel()
    private let nameLabel = UILabel()
    private let meetingHostTitleLabel = UILabel()
    private let meetingHostNameLabel = UILabel()
    private let durationLabel = UILabel()
    private let meetingIDLabel = UILabel()
    private let meetingURLLabel = UILabel()
    private let e2eeTitleLabel = UILabel()
    
    private var infoContainer = UIScrollView()
    
    private let meetingNameRowView = UIView()
    private let meetingHostRowView = UIView()
    private let meetingIDRowView = UIView()
    private let meetingURLRowView = UIView()
    private let meetingURLContentView = UIView()
    private let e2eeRowView = UIView()
    
    private var titleLabelTopConstraint: NSLayoutConstraint?
    
    private let copyURLButton = UIButton()
    
    override func setupPopupView() {
        super.setupPopupView()
        
        titleLabel.text = "Meeting details"
        titleLabel.accessibilityLabel = "Meeting details"
        popupView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.font = UIFont.systemFont(ofSize: 16)

        titleLabel.textColor = RCVColor.get(.neutralF01)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: popupView.trailingAnchor),
        ])
        
        titleLabelTopConstraint = titleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: style.titleLabelTopSpacing)
        titleLabelTopConstraint?.isActive = true
        
        lineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
    }
    
    override func setupContentView() {
        popupView.addSubview(infoContainer)
        infoContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let window: UIWindow? = UIApplication.shared.windows.filter {
            $0.isKeyWindow
        }.first
        
        let safeAreaInsetBottom = window?.safeAreaInsets.bottom ?? 0
        infoContainer.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -safeAreaInsetBottom).isActive = true
        infoContainer.leadingAnchor.constraint(equalTo: popupView.safeLeadingAnchor).isActive = true
        infoContainer.trailingAnchor.constraint(equalTo: popupView.safeTrailingAnchor).isActive = true
        infoContainer.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 0).isActive = true
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        infoContainer.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: infoContainer.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: infoContainer.leadingAnchor, constant: 24),
            stackView.widthAnchor.constraint(equalTo: infoContainer.widthAnchor, constant: -48),
        ])
        
        let constraint = infoContainer.heightAnchor.constraint(equalTo: stackView.heightAnchor, constant: 0)
        constraint.priority = UILayoutPriority(rawValue: 749)
        constraint.isActive = true
        
        stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: infoContainer.bottomAnchor, constant: 0)
        stackViewBottomConstraint?.priority = .defaultHigh
        stackViewBottomConstraint?.isActive = true
        
        stackView.addArrangedSubview(meetingNameRowView)

        meetingNameRowView.addSubview(nameLabel)
        nameLabel.numberOfLines = 2
        nameLabel.textColor = RCVColor.get(.neutralF01)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.setContentHuggingPriority(.required, for: .vertical)
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: meetingNameRowView.topAnchor, constant: 24),
            nameLabel.leadingAnchor.constraint(equalTo: meetingNameRowView.leadingAnchor, constant: 0),
            nameLabel.trailingAnchor.constraint(equalTo: meetingNameRowView.trailingAnchor, constant: 0),
        ])
        nameLabel.accessibilityIdentifier = "meetingTitle"
        
        durationLabel.accessibilityIdentifier = "meetingDuration"
        meetingNameRowView.addSubview(durationLabel)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.textColor = RCVColor.get(.neutralF01)
        durationLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            durationLabel.bottomAnchor.constraint(equalTo: meetingNameRowView.bottomAnchor, constant: 0),
            durationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0),
            durationLabel.trailingAnchor.constraint(lessThanOrEqualTo: meetingNameRowView.trailingAnchor, constant: 0),
        ])
        
        stackView.addArrangedSubview(meetingHostRowView)
        meetingHostTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        meetingHostTitleLabel.text = "Host"
        meetingHostTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        meetingHostTitleLabel.textColor = RCVColor.get(.neutralF01)
        meetingHostTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        meetingHostRowView.isAccessibilityElement = true
        meetingHostRowView.accessibilityIdentifier = "meetingHost"
        meetingHostRowView.addSubview(meetingHostTitleLabel)
        NSLayoutConstraint.activate([
            meetingHostTitleLabel.leadingAnchor.constraint(equalTo: meetingHostRowView.leadingAnchor),
            meetingHostTitleLabel.topAnchor.constraint(equalTo: meetingHostRowView.topAnchor),
            meetingHostTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: meetingHostRowView.bottomAnchor),
        ])
        
        meetingHostNameLabel.translatesAutoresizingMaskIntoConstraints = false
        meetingHostNameLabel.text = "The host hasn't joined yet"
        meetingHostNameLabel.textColor = RCVColor.get(.neutralF01)
        meetingHostNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        meetingHostRowView.addSubview(meetingHostNameLabel)
        NSLayoutConstraint.activate([
            meetingHostNameLabel.topAnchor.constraint(equalTo: meetingHostRowView.topAnchor),
            meetingHostNameLabel.bottomAnchor.constraint(equalTo: meetingHostRowView.bottomAnchor),
            meetingHostNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: meetingHostRowView.trailingAnchor),
        ])
        meetingHostRowView.accessibilityLabel = "Host" + "," + "The host hasn't joined yet"
        contentSpacingConstraint = meetingHostNameLabel.leadingAnchor.constraint(equalTo: meetingHostTitleLabel.trailingAnchor, constant: style.contentSpacing)
        contentSpacingConstraint?.isActive = true
        
        stackView.addArrangedSubview(meetingIDRowView)
        
        let meetingIDTitleLabel = UILabel()
        meetingIDTitleLabel.text = "Meeting ID"
        meetingIDTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        meetingIDTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        meetingIDTitleLabel.textColor = RCVColor.get(.neutralF01)
        meetingIDTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        meetingIDRowView.addSubview(meetingIDTitleLabel)
        NSLayoutConstraint.activate([
            meetingIDTitleLabel.leadingAnchor.constraint(equalTo: meetingIDRowView.leadingAnchor),
            meetingIDTitleLabel.topAnchor.constraint(equalTo: meetingIDRowView.topAnchor),
            meetingIDTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: meetingIDRowView.bottomAnchor),
            meetingIDTitleLabel.widthAnchor.constraint(equalTo: meetingHostTitleLabel.widthAnchor),
        ])
        meetingIDRowView.isAccessibilityElement = true
        meetingIDRowView.accessibilityIdentifier = "meetingIdNumber"
        meetingIDLabel.translatesAutoresizingMaskIntoConstraints = false
        meetingIDLabel.textColor = RCVColor.get(.neutralF01)
        meetingIDLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        meetingIDRowView.addSubview(meetingIDLabel)
        NSLayoutConstraint.activate([
            meetingIDLabel.leadingAnchor.constraint(equalTo: meetingHostNameLabel.leadingAnchor),
            meetingIDLabel.topAnchor.constraint(equalTo: meetingIDRowView.topAnchor),
            meetingIDLabel.bottomAnchor.constraint(equalTo: meetingIDRowView.bottomAnchor),
        ])
        
        stackView.addArrangedSubview(meetingURLRowView)
        let meetingURLTitleLabel = UILabel()
        meetingURLTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        meetingURLTitleLabel.text = "Meeting URL"
        meetingURLTitleLabel.accessibilityIdentifier = "meetingURLTitle"
        meetingURLTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        meetingURLTitleLabel.textColor = RCVColor.get(.neutralF01)
        meetingURLTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        meetingURLRowView.addSubview(meetingURLContentView)
        meetingURLContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            meetingURLContentView.leadingAnchor.constraint(equalTo: meetingURLRowView.leadingAnchor),
            meetingURLContentView.topAnchor.constraint(equalTo: meetingURLRowView.topAnchor),
            meetingURLContentView.bottomAnchor.constraint(equalTo: meetingURLRowView.bottomAnchor),
        ])
        
        meetingURLContentView.addSubview(meetingURLTitleLabel)
        meetingURLContentView.isAccessibilityElement = true
        meetingURLContentView.accessibilityIdentifier = "meetingLink"
        NSLayoutConstraint.activate([
            meetingURLTitleLabel.leadingAnchor.constraint(equalTo: meetingURLContentView.leadingAnchor),
            meetingURLTitleLabel.topAnchor.constraint(equalTo: meetingURLContentView.topAnchor),
            meetingURLTitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: meetingURLContentView.bottomAnchor),
            meetingURLTitleLabel.widthAnchor.constraint(equalTo: meetingIDTitleLabel.widthAnchor),
        ])
        
        meetingURLLabel.translatesAutoresizingMaskIntoConstraints = false
        meetingURLLabel.numberOfLines = 0
        meetingURLLabel.textColor = RCVColor.get(.neutralF01)
        meetingURLLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        meetingURLContentView.addSubview(meetingURLLabel)
        meetingURLLabel.lineBreakMode = .byTruncatingTail
        meetingURLLabel.accessibilityIdentifier = "meetingURLLabel"
        NSLayoutConstraint.activate([
            meetingURLLabel.leadingAnchor.constraint(equalTo: meetingHostNameLabel.leadingAnchor),
            meetingURLLabel.topAnchor.constraint(equalTo: meetingURLContentView.topAnchor),
            meetingURLLabel.trailingAnchor.constraint(lessThanOrEqualTo: meetingURLContentView.trailingAnchor, constant: 0),
            meetingURLLabel.bottomAnchor.constraint(equalTo: meetingURLContentView.bottomAnchor),
        ])
        
        copyURLButton.accessibilityLabel = "Copy meeting URL"
        copyURLButton.accessibilityIdentifier = "meetingURLCopyButtion"
        copyURLButton.translatesAutoresizingMaskIntoConstraints = false
        copyURLButton.addTarget(self, action: #selector(actionCopyMeetingURL(sender:)), for: .touchUpInside)
        copyURLButton.setImage(RCVColor.image(named: "iconsCopyInfo"), for: .normal)
        meetingURLRowView.addSubview(copyURLButton)
        NSLayoutConstraint.activate([
            copyURLButton.trailingAnchor.constraint(equalTo: meetingURLRowView.trailingAnchor),
            copyURLButton.topAnchor.constraint(equalTo: meetingURLRowView.topAnchor),
            copyURLButton.widthAnchor.constraint(equalToConstant: 24),
            copyURLButton.heightAnchor.constraint(equalToConstant: 24),
            meetingURLContentView.trailingAnchor.constraint(equalTo: copyURLButton.leadingAnchor, constant: -19),
        ])
    }
    
    override func updateViewsAccessibility() {
        dismissView.accessibilityIdentifier = "MeetingInfoDismissView"
        slideLineView.accessibilityLabel = "Hide meeting information dialog"
    }
    
    func show(inView view: UIView) {
        isShowing = true
        updateContent()
        super.showInfo(inView: view)
    }
    
    private func updateContent() {
        let meetingController = RCVMeetingDataSource.getMeetingController()
        let meetingInfo = meetingController?.getMeetingInfo()
        let meetingURL = meetingInfo?.meetingLink()
        let meetingTitle = meetingInfo?.meetingName()
        let hostName = meetingInfo?.hostName()
        let meetingID = meetingInfo?.meetingId()
        
        nameLabel.text = meetingTitle
        meetingURLLabel.text = meetingURL
        
        meetingURLContentView.accessibilityLabel = "Meeting URL" + "," + meetingURL!
        
        meetingHostNameLabel.text = hostName
        meetingHostRowView.accessibilityLabel = "Host" + "," + hostName!
        
        meetingIDLabel.text = meetingID
        meetingIDRowView.accessibilityLabel = "Meeting ID" + "," + meetingID!
    }
    
    func setMeetingDuration(duration: String) {
        durationLabel.text = duration
    }
    
    @objc func actionCopyMeetingURL(sender: UIButton?) {
        UIPasteboard.general.string = meetingURLLabel.text
        showToastThenDismiss("Meeting URL copied")
    }
    
    private func showToastThenDismiss(_ string: String) {
        Toast.show(message: "Meeting URL copied", duration: 3.0, view: self.superview!)
        dismiss()
    }
}
