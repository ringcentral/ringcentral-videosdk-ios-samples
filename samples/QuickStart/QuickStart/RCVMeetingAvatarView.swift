//
//  RCVMeetingAvatarView..swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 2/16/23.
//

import UIKit
import rcvsdk

open class RCVMeetingAvatarView: UIView {
    public var nameLabel: UILabel = UILabel()
    public var thumbnailImageView: UIImageView = UIImageView()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    fileprivate func _init() {
        layer.cornerRadius = frame.width / 2.0
        
        accessibilityIdentifier = "avatarView"
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView = UIImageView()
        thumbnailImageView.backgroundColor = UIColor.clear
        thumbnailImageView.layer.masksToBounds = true
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.accessibilityIdentifier = "thumbnailImageView"
        thumbnailImageView.contentMode = .scaleAspectFill
        addSubview(thumbnailImageView)

        thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0).isActive = true
        thumbnailImageView.topAnchor.constraint(equalTo: topAnchor, constant: 0.0).isActive = true
        thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0).isActive = true
        thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0).isActive = true
        thumbnailImageView.layer.cornerRadius = frame.width / 2.0

        nameLabel = UILabel()
        nameLabel.isHidden = true
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textColor = RCVColor.get(.neutralF01)
        nameLabel.textAlignment = .center
        nameLabel.accessibilityIdentifier = "nameLabel"
        thumbnailImageView.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: thumbnailImageView.centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: thumbnailImageView.centerYAnchor).isActive = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.width / 2.0
        thumbnailImageView.layer.cornerRadius = frame.width / 2.0
    }
    
    open func setAvatarImage(name: String,
                                colorType: Int64) {
        nameLabel.isHidden = false
        nameLabel.text = name
        thumbnailImageView.image = rcBackgroundImageFor(colorType)
    }
    
    public func rcBackgroundImageFor(_ type: Int64, largeSize: Bool = false) -> UIImage {
        switch type {
        case 0:
            return largeSize ? RCVIconUtils.shared.rcTomatoOnNavigation : RCVIconUtils.shared.rcTomato
        case 1:
            return largeSize ? RCVIconUtils.shared.rcBlueberryOnNavigation : RCVIconUtils.shared.rcBlueberry
        case 2:
            return largeSize ? RCVIconUtils.shared.rcOasisOnNavigation : RCVIconUtils.shared.rcOasis
        case 3:
            return largeSize ? RCVIconUtils.shared.rcGoldOnNavigation : RCVIconUtils.shared.rcGold
        case 4:
            return largeSize ? RCVIconUtils.shared.rcSageOnNavigation : RCVIconUtils.shared.rcSage
        case 5:
            return largeSize ? RCVIconUtils.shared.rcAshOnNavigation : RCVIconUtils.shared.rcAsh
        case 6:
            return largeSize ? RCVIconUtils.shared.rcPersimmonOnNavigation : RCVIconUtils.shared.rcPersimmon
        case 7:
            return largeSize ? RCVIconUtils.shared.rcPearOnNavigation : RCVIconUtils.shared.rcPear
        case 8:
            return largeSize ? RCVIconUtils.shared.rcBrassOnNavigation : RCVIconUtils.shared.rcBrass
        case 9:
            return largeSize ? RCVIconUtils.shared.rcLakeOnNavigation : RCVIconUtils.shared.rcLake
        default:
            return UIImage()
        }
    }
}
