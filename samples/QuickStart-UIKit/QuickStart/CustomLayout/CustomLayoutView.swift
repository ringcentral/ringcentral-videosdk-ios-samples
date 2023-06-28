//
//  CustomLayoutView.swift
//  RCV-UIKit-Example
//
//  Created by Simon Xiang on 2023/6/25.
//

import UIKit
import Combine
import rcvsdk

class CustomLayoutView: UIView {
    private var localView: CustomParticipantView = CustomParticipantView()
    private var participantViews: [CustomParticipantView] = [CustomParticipantView(), CustomParticipantView()]
    var localVideoCanvas: RCVideoCanvas?
    
    private var cancelable = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupLocalVideoCanvas()
        self.localView.updateParticipant(participant: CustomLayoutViewController.customLayoutModel?.getMySelf())
        binModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func binModel() {
        CustomLayoutViewController.customLayoutModel?.$participantsList.sink { [weak self]
            participantsList in
            guard let self else { return }
            self.updateParticipantCanvas(participants: participantsList)
        }.store(in: &cancelable)
        
        CustomLayoutViewController.customLayoutModel?.$perPageParticipants.sink { [weak self]
            perPageParticipants in
            guard let self else { return }
            self.updateParticipantCanvas(participants: perPageParticipants)
        }.store(in: &cancelable)
        
        CustomLayoutViewController.customLayoutModel?.$localVideoMute.sink { [weak self]
            localVideoMute in
            guard let self else { return }
            self.updateLocalViewState(isMute: localVideoMute)
        }.store(in: &cancelable)
        
        CustomLayoutViewController.customLayoutModel?.$localAudioMute.sink { [weak self]
            localAudioMute in
            guard let self else { return }
            self.updateLocalAudioState(isMute: localAudioMute)
        }.store(in: &cancelable)
    }
    
    private func updateLocalAudioState(isMute: Bool) {
        let color = isMute ? UIColor.gray.cgColor : UIColor.cyan.cgColor
        localView.layer.borderColor = color
    }
    
    private func updateParticipantCanvas(participants: [RemoteParticipantInfo]) {
        var index: Int = 0
        while index < self.participantViews.count {
            if index < participants.count {
                CustomLayoutViewController.customLayoutModel?.attachRemoteVideoView(participant: participants[index].participant!, view: self.participantViews[index].getVideoView())
                self.participantViews[index].updateParticipant(participant: participants[index].participant!)
                
                self.participantViews[index].layer.borderColor = UIColor.gray.cgColor
                if participants[index].participant!.inAudioStreamActivity() != .inactive {
                    if participants[index].isAudioMute == false {
                        self.participantViews[index].layer.borderColor = UIColor.cyan.cgColor
                    }
                }
            } else {
                self.participantViews[index].layer.borderColor = UIColor.gray.cgColor
                self.participantViews[index].updateParticipant(participant: nil)
            }
            
            index = index + 1
        }
    }
    
    private func setupView(){
        let with = self.width
        
        addSubview(localView)
        localView.layer.borderWidth = 2
        localView.layer.borderColor = UIColor.gray.cgColor
        
        localView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            localView.leftAnchor.constraint(equalTo: localView.superview!.leftAnchor),
            localView.rightAnchor.constraint(equalTo: localView.superview!.rightAnchor),
            localView.topAnchor.constraint(equalTo: localView.superview!.topAnchor),
        ])
        localView.heightAnchor.constraint(equalToConstant: height/4).isActive = true
        
        
        addSubview(participantViews[0])
        participantViews[0].layer.borderWidth = 2
        participantViews[0].layer.borderColor = UIColor.gray.cgColor
        participantViews[0].translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            participantViews[0].leftAnchor.constraint(equalTo: participantViews[0].superview!.leftAnchor),
            participantViews[0].topAnchor.constraint(equalTo: localView.bottomAnchor),
            participantViews[0].bottomAnchor.constraint(equalTo: participantViews[0].superview!.bottomAnchor),
        ])
        participantViews[0].widthAnchor.constraint(equalToConstant: with/2).isActive = true
        
        addSubview(participantViews[1])
        participantViews[1].layer.borderWidth = 2
        participantViews[1].layer.borderColor = UIColor.gray.cgColor
        participantViews[1].translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            participantViews[1].topAnchor.constraint(equalTo: localView.bottomAnchor),
            participantViews[1].rightAnchor.constraint(equalTo: participantViews[1].superview!.rightAnchor),
            participantViews[1].bottomAnchor.constraint(equalTo: participantViews[1].superview!.bottomAnchor),
        ])
        participantViews[1].widthAnchor.constraint(equalToConstant: with/2).isActive = true
    }
    
    private func updateLocalViewState(isMute: Bool) {
        self.localView.updateLocalViewState(isMute: isMute)
    }
    
    private func setupLocalVideoCanvas() {
        CustomLayoutViewController.customLayoutModel?.attachLocalVideoView(view: self.localView.getVideoView())
    }
}
