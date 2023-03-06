//
//  AudioEventHandler.swift
//  RcvSwiftSample1v1meeting
//
//  Created by Yi Ke on 7/21/22.
//

import rcvsdk

class AudioEventHandler: RcvAudioEventHandler
{
    weak var delegate: RcvAudioEventHandler?
    
    init(delegate: RcvAudioEventHandler) {
        self.delegate = delegate
    }
    
    func onLocalAudioMuteChanged(_ muted: Bool) {
        delegate?.onLocalAudioMuteChanged(muted)
    }
    
    func onLocalAudioStreamStateChanged(_ state: RcvLocalAudioStreamState, error: RcvLocalAudioError) {
        delegate?.onLocalAudioStreamStateChanged(state, error: error)
    }
    
    func onRemoteAudioMuteChanged(_ participant: RcvIParticipant?, muted: Bool) {
        delegate?.onRemoteAudioMuteChanged(participant, muted: muted)
    }
    
    func onUnmuteAudioDemand() {
        delegate?.onUnmuteAudioDemand()
    }
    
    func onAudioRouteChanged(_ audioRouteType: RcvAudioRouteType) {
        delegate?.onAudioRouteChanged(audioRouteType)
    }
    
    func onFirstLocalAudioFrame(_ elapsed: Int32) {
    }
}
