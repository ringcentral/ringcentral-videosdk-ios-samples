//
//  CustomParticipantView.swift
//  RCV-UIKit-Example
//
//  Created by Simon Xiang on 2023/6/27.
//

import UIKit
import rcvsdk

class CustomParticipantView: UIView {
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.clear
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        label.textColor = .white
        label.accessibilityIdentifier = "custom layout info label"
        label.text = "No participant"
        return label
    }()
    
    let videoView: UIView = UIView()
    
    private var participant: RcvIParticipant? {
        didSet {
            updateTableInfo()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getVideoView()-> UIView {
        return self.videoView
    }
    
    func updateLocalViewState(isMute: Bool) {
        self.videoView.isHidden = isMute ? true : false
        self.infoLabel.isHidden = isMute ? false : true
    }
    
    private func setupView() {
        self.addSubview(videoView)
        videoView.makeConstraintsToBindToSuperview()
        videoView.isHidden  = true
        
        self.addSubview(self.infoLabel)
            
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: infoLabel.superview!.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: infoLabel.superview!.centerYAnchor),
        ])
    }
    
    func updateParticipant(participant: RcvIParticipant?) {
        self.participant = participant
    }
    
    private func updateTableInfo() {
        if let name = self.participant?.displayName() {
            self.infoLabel.text = name
        } else {
            self.infoLabel.text = "No participant"
        }
        
        if self.participant?.isVideoOn() ?? false {
            self.videoView.isHidden = false
            self.infoLabel.isHidden = true
        } else {
            self.videoView.isHidden = true
            self.infoLabel.isHidden = false
        }
    }
}
