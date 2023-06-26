//
//  RCVButtonSource.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

class RCVToolBarButton: RCVBaseButton {
    private var backgroundImage: UIImage?
    
    var viewModel: RCVToolBarItem? {
        didSet {
            update()
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    private func _init() {
        space = 0
        isAccessibilityElement = true
        let leadingConstraint = contentView.leadingAnchor.constraint(equalTo: leadingAnchor)
        leadingConstraint.priority = .required
        leadingConstraint.isActive = true

        let topAnchorConstraint = contentView.topAnchor.constraint(equalTo: topAnchor)
        topAnchorConstraint.priority = .required
        topAnchorConstraint.isActive = true
    }
    
    func update() {
        guard let viewModel = viewModel else {
            return
        }
        if backgroundImage == nil {
            backgroundImage = RCVColor.uiImageByColor(RCVColor.get(.neutralB05))
        }

        let tuple = viewModel.modelTuple()
        textLabel.text = tuple.title
        
        let image: UIImage?
        switch tuple.iconName {
        case let .image(name):
            image = RCVColor.image(named: name)
        }
        
        setBackgroundImage(backgroundImage, for: .highlighted)
        backgroundColor = .clear
        textLabel.textColor = RCVColor.get(.neutralF01)
        iconView.image = image
    }
}

class RCVBaseButton: UIButton {
    private var iconLeftConstraint: NSLayoutConstraint?
    private var iconRightConstraint: NSLayoutConstraint?
    private var iconTopConstraint: NSLayoutConstraint?
    private var labeLeftConstraint: NSLayoutConstraint?
    private var labelRightConstraint: NSLayoutConstraint?
    private var labelBottomConstraint: NSLayoutConstraint?
    private var spaceContraint: NSLayoutConstraint?
    
    public let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = false
        return view
    }()
    
    public let iconView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .center
        imgView.isUserInteractionEnabled = false
        imgView.accessibilityIdentifier = "iconView"
        return imgView
    }()
    
    public let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.accessibilityIdentifier = "textLabel"
        return label
    }()
    
    open var space: CGFloat = 5 {
        didSet {
            spaceContraint?.constant = space
            setNeedsLayout()
        }
    }
    
    open var inset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            iconLeftConstraint?.constant = inset.left
            iconRightConstraint?.constant = inset.right
            iconTopConstraint?.constant = inset.top
            labeLeftConstraint?.constant = inset.left
            labelRightConstraint?.constant = inset.right
            labelBottomConstraint?.constant = inset.bottom
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    open func setup() {
        isUserInteractionEnabled = true
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerYAnchor.constraint(equalTo: centerYAnchor),
            contentView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])

        contentView.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconLeftConstraint = iconView.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: inset.left)
        iconLeftConstraint?.isActive = true
        iconRightConstraint = iconView.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: inset.right)
        iconRightConstraint?.isActive = true
        iconView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        iconTopConstraint = iconView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset.top)
        iconTopConstraint?.isActive = true

        contentView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        labeLeftConstraint = textLabel.leftAnchor.constraint(greaterThanOrEqualTo: contentView.leftAnchor, constant: inset.left)
        labeLeftConstraint?.isActive = true

        labelRightConstraint = textLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: inset.right)
        labelRightConstraint?.isActive = true

        labelBottomConstraint = textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: inset.bottom)
        labelBottomConstraint?.isActive = true

        textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        spaceContraint = textLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: space)
        spaceContraint?.isActive = true
    }
}

class RCVMicrophoneButton: RCVToolBarButton {
    private struct Icon {
        static let unmute = UIImage(named: "iconsMic")
        static let speaking = UIImage(named: "iconsMicActive")
    }
    
    //func update() {
        //super.update()
    //}
}

class RCVParticipantsButton: RCVToolBarButton {
    
}

public class InviteButton: UIButton {
    private let kHeight: CGFloat = 55
    private let kRadius: CGFloat = 14.0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        updateBackgroundImage()
        imageView?.contentMode = .center
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateBackgroundImage()
        imageView?.contentMode = .center
    }
    
    private func drawAddIcon(radius: CGFloat = 14, fill: Bool = false, iconColor: UIColor) -> UIImage? {
        let bagColor = iconColor.withAlphaComponent(0.4)
        let rect = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        let img = UIImage.fontAwesomeIcon(name: GFIName.GFIInvite.rawValue, iconColor: RCVColor.get(.labelBlue02), fontSize: 12, backgroundColor: UIColor.clear)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)

        let bezier = UIBezierPath(roundedRect: rect, cornerRadius: rect.size.width / 2)
        bezier.close()
        bezier.addClip()
        bezier.lineWidth = 2

        if fill {
            bagColor.setFill()
            bezier.fill()
        } else {
            bagColor.setStroke()
            bezier.stroke()
        }

        var imgRect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        imgRect.origin.y = (rect.height - img.size.height) / 2.0
        imgRect.origin.x = (rect.width - img.size.width) / 2.0

        img.draw(in: imgRect)

        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage
    }

    private func updateBackgroundImage() {
        setImage(drawAddIcon(radius: kRadius, fill: false, iconColor: RCVColor.get(.labelBlue02)), for: UIControl.State())
        setImage(drawAddIcon(radius: kRadius, fill: true, iconColor: RCVColor.get(.labelBlue02)), for: .highlighted)
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false else {
            return
        }
        updateBackgroundImage()
    }
}

class ParticipantStatusButton: UIButton {
    var iconLeftPaddingConstraint: NSLayoutConstraint?
    
    lazy var lockIconView: UIImageView = {
        let view = UIImageView()
        view.image = RCVColor.image(named: "ico_audiolock_participantslist")
        return view
    }()
    
    var isLock: Bool = true {
        didSet {
            lockIconView.isHidden = !isLock
            accessibilityValue = isLock ? "Locked" : ""
        }
    }

    var iconLeftPadding: CGFloat = 12 {
        didSet {
            iconLeftPaddingConstraint?.constant = iconLeftPadding
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        lockIconView.isHidden = true
        addSubview(lockIconView)
        lockIconView.translatesAutoresizingMaskIntoConstraints = false
        if let imageView = imageView {
            NSLayoutConstraint.activate([
                lockIconView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10.0),
                lockIconView.widthAnchor.constraint(equalToConstant: 16),
                lockIconView.heightAnchor.constraint(equalToConstant: 16),
            ])
            iconLeftPaddingConstraint = lockIconView.leftAnchor.constraint(equalTo: imageView.leftAnchor, constant: 12.0)
            iconLeftPaddingConstraint?.isActive = true
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bringSubviewToFront(lockIconView)
    }
}
