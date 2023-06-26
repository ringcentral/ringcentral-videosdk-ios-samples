//
//  RCVParticipantInviteCell.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 2/13/23.
//

import UIKit
import rcvsdk

class ParticipantInviteCell: UITableViewCell {
    fileprivate var kDefaultMargin: CGFloat { return 20 }
    fileprivate var kDefaultMarginForLabel: CGFloat { return 20 }
    private let kDefaultAvatarSize: CGFloat = 32.0
    
    var iconView: UIButton = {
        let view = InviteButton()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        titleLabel.textColor = RCVColor.get(.labelBlue02)
        titleLabel.text = "Invite others"
        titleLabel.backgroundColor = .clear
        titleLabel.accessibilityIdentifier = "inviteLabel"
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
        backgroundColor = RCVColor.get(.neutralB05)
        contentView.backgroundColor = RCVColor.get(.neutralB05)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = RCVColor.get(.neutralB02)
        contentView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: kDefaultMargin),
            iconView.widthAnchor.constraint(equalToConstant: kDefaultAvatarSize),
            iconView.heightAnchor.constraint(equalToConstant: kDefaultAvatarSize),
            iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12.0),
            iconView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12.0),
        ])

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: kDefaultMarginForLabel),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}
