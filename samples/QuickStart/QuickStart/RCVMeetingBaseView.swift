//
//  RCVMeetingBaseView.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

// Background blur
class RCVMeetingBlurView: UIImageView {
    private lazy var orentationDict: [UIInterfaceOrientation: String] = {
        let dict = [UIInterfaceOrientation: String]()
        return dict
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        image = RCVColor.image(named: "active_speaking_bg.png")
        contentMode = .scaleToFill
        backgroundColor = RCVColor.get(.neutralB05)
    }
    
    private func setImage(_ image: String, for orientation: UIInterfaceOrientation) {
        orentationDict[orientation] = image
    }
    
    private func updateBlurView() {
        let orientation = UIApplication.shared.statusBarOrientation
        if let imageStr = orentationDict[orientation] {
            image = RCVColor.image(named: imageStr)
        }
    }
    
    public func setupDefaultImages() {
        /// Config blurView transition image
        contentMode = .scaleAspectFill
        setImage("inmeetingBG_portrait", for: .portrait)
        setImage("inmeetingBG_portrait", for: .portraitUpsideDown)
        setImage("inmeetingBG_portrait", for: .unknown)
        setImage("inmeetingBG_landscape", for: .landscapeLeft)
        setImage("inmeetingBG_landscape", for: .landscapeRight)
        if RCVMeetingDataSource.isIPhone() {
            setImage("inmeetingBG_landscape_iphone", for: .landscapeLeft)
            setImage("inmeetingBG_landscape_iphone", for: .landscapeRight)
        }
        updateBlurView()
    }
}

class ParticipantStatusContentView: UIView {
    var contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = NSTextAlignment.left
        var font = UIFont.preferredFont(forTextStyle: .footnote)
        if font.pointSize > UIFont.preferredFontMaximumSize(.footnote) {
            let fontSize = UIFont.preferredFontMaximumSize(.footnote)
            let weight = UIFont.preferredFontDefaultWeight(.footnote)
            font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        }
        label.textColor = RCVColor.get(.neutralF05)
        label.accessibilityIdentifier = "contentLabel"
        label.backgroundColor = .clear
        return label
    }()

    var fitView: UIView = {
        let view = UIView()
        return view
    }()

    var contentStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        view.spacing = 4
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        addSubview(contentStackView)
        contentStackView.makeConstraintsToBindToSuperview()

        contentStackView.addArrangedSubview(contentLabel)
        contentStackView.addArrangedSubview(fitView)

    }

    func updateContent(text: String) {
        contentLabel.text = text
    }

    func setConetentLable(isHidden: Bool) {
        contentLabel.isHidden = isHidden
    }
}
