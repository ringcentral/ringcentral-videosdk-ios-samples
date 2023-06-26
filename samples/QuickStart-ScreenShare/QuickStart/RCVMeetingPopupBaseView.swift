//
//  RCVMeetingPopupBaseView.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

class RCVMeetingPopupBaseView: UIView {
    enum Style {
        case fullWidth
        case fixWidth

        var bottomSpacing: CGFloat {
            switch self {
            case .fixWidth: return 36
            case .fullWidth: return 40
            }
        }

        var contentSpacing: CGFloat {
            switch self {
            case .fixWidth: return 20
            case .fullWidth: return 16
            }
        }

        var titleLabelTopSpacing: CGFloat {
            switch self {
            case .fixWidth: return 24
            case .fullWidth: return 42
            }
        }
    }
    
    var style = Style.fullWidth {
        didSet {
            //updatePopupStyle()
        }
    }
    
    var dismissBlock: (() -> Void)?
    
    var isShowing = false
    let fixMaxWidth: CGFloat = 476.0
    
    lazy var dismissView: UIView = UIView()
    var popupView = UIView()
    var slideGestureView = UIView()
    var slideLineView = UIView()
    let lineView = UIView()
    
    var popupFullWidthConstraint: NSLayoutConstraint?
    var popupFixWidthConstraint: NSLayoutConstraint?
    var popUpBottomContraint: NSLayoutConstraint?
    var popUpShowingTopContraint: NSLayoutConstraint?
    var popUpTopContraint: NSLayoutConstraint?
    var stackViewBottomConstraint: NSLayoutConstraint?
    var contentSpacingConstraint: NSLayoutConstraint?
    var popUpShowingTopContraintConstant: CGFloat = 0
    
    var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        setupPopupView()
        setupContentView()
        initializedCorelib()
        updateAccessibilityElements()
    }
    
    func initializedCorelib() {}

    func setupContentView() {}

    func updateViewsAccessibility() {}
    
    func updatePopupTopSpacing(_ spacing: CGFloat) {
        popUpShowingTopContraintConstant = spacing
        popUpShowingTopContraint?.constant = popUpShowingTopContraintConstant
    }
    
    private func updateAccessibilityElements() {
        accessibilityViewIsModal = true
    }
    
    func setupPopupView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionDismiss))
        tapGesture.delaysTouchesBegan = true
        dismissView.addGestureRecognizer(tapGesture)
        
        addSubview(dismissView)
        dismissView.makeConstraintsToBindToSuperview()
        
        addSubview(popupView)
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        popupFullWidthConstraint = popupView.widthAnchor.constraint(equalTo: widthAnchor)
        popupFixWidthConstraint = popupView.widthAnchor.constraint(equalToConstant: fixMaxWidth)
        popupFullWidthConstraint?.isActive = true
        popupFixWidthConstraint?.isActive = false
        
        popUpBottomContraint = popupView.bottomAnchor.constraint(equalTo: bottomAnchor)
        popUpShowingTopContraint = popupView.topAnchor.constraint(greaterThanOrEqualTo: safeTopAnchor, constant: popUpShowingTopContraintConstant)
        popUpTopContraint = popupView.topAnchor.constraint(equalTo: bottomAnchor)
        popUpShowingTopContraint?.isActive = false
        popUpTopContraint?.isActive = true
        popUpBottomContraint?.isActive = false
        
        
        popupView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        popupView.clipsToBounds = true
        popupView.layer.cornerRadius = 14
        
        popupView.addSubview(effectView)
        effectView.makeConstraintsToBindToSuperview()
        
        slideGestureView.backgroundColor = UIColor.clear
        slideGestureView.translatesAutoresizingMaskIntoConstraints = false
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(actionSlideLineButton(sender:)))
        slideGestureView.addGestureRecognizer(panGesture)
        popupView.addSubview(slideGestureView)
        
        slideLineView.isAccessibilityElement = true
        slideLineView.accessibilityTraits = .button
        
        slideLineView.backgroundColor = UIColor(red: 213 / 255, green: 211 / 255, blue: 211 / 255, alpha: 0.6)
        slideLineView.clipsToBounds = true
        slideLineView.isUserInteractionEnabled = false
        slideLineView.layer.cornerRadius = 4 / 2
        slideGestureView.addSubview(slideLineView)
        slideLineView.translatesAutoresizingMaskIntoConstraints = false
        slideLineView.centerXAnchor.constraint(equalTo: slideGestureView.centerXAnchor).isActive = true
        slideLineView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        slideLineView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        slideLineView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 16).isActive = true
        
        popupView.addSubview(lineView)
        lineView.makeConstraints { [
            $0.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale),
            $0.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 0),
            $0.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: 0),
        ] }
        lineView.backgroundColor = RCVColor.get(.neutralF01).withAlphaComponent(0.3)
        
        NSLayoutConstraint.activate([
            slideGestureView.widthAnchor.constraint(equalTo: popupView.widthAnchor),
            slideGestureView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            slideGestureView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 0),
            slideGestureView.bottomAnchor.constraint(equalTo: lineView.topAnchor),
        ])
    }
    
    @objc func actionDismiss() {
        dismiss()
    }
    
    @objc private func actionSlideLineButton(sender: UIPanGestureRecognizer) {
    }
    
    func dismiss(_ complete: (() -> Void)? = nil) {
        guard isShowing else { return }
        layoutIfNeeded()
        
        popUpBottomContraint?.isActive = false
        popUpShowingTopContraint?.isActive = false
        popUpTopContraint?.isActive = true
        
        UIView.animate(withDuration: 0.2, animations: {
            self.layoutIfNeeded()
        }) { _ in
            if let animationComplete = complete {
                animationComplete()
            }
            self.isShowing = false
            self.removeFromSuperview()
            self.dismissBlock?()
        }
    }
    
    func updatePopupStyle() {
        if style == .fixWidth {
            popupFullWidthConstraint?.isActive = false
            popupFixWidthConstraint?.isActive = true
        } else {
            popupFixWidthConstraint?.isActive = false
            popupFullWidthConstraint?.isActive = true
        }
        stackViewBottomConstraint?.constant = -style.bottomSpacing
        contentSpacingConstraint?.constant = style.contentSpacing
    }
    
    func showInfo(inView view: UIView) {
        isShowing = true
        view.addSubview(self)
        makeConstraintsToBindToSuperview()
        updatePopupStyle()
        layoutIfNeeded()
        popUpTopContraint?.isActive = false
        popUpBottomContraint?.isActive = true
        popUpShowingTopContraint?.isActive = true
        popUpBottomContraint?.constant = 0
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
}
