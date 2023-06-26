//
//  VideoEventHandler.swift
//  RcvSwiftSample1v1meeting
//
//  Created by Yi Ke on 7/21/22.
//

import rcvsdk

class VideoEventHandler: RcvVideoEventHandler
{
    weak var delegate: RcvVideoEventHandler?
    
    init(delegate: RcvVideoEventHandler) {
        self.delegate = delegate
    }
    
    func onLocalVideoMuteChanged(_ muted: Bool) {
        delegate?.onLocalVideoMuteChanged(muted)
    }
    
    func onRemoteVideoMuteChanged(_ participant: RcvIParticipant?, muted: Bool) {
        delegate?.onRemoteVideoMuteChanged(participant, muted: muted)
    }
    
    func onUnmuteVideoDemand() {
        delegate?.onUnmuteVideoDemand()
    }
    
    func onFirstLocalVideoFrame(_ width: Int32, height: Int32, elapsed: Int32) {
        delegate?.onFirstLocalVideoFrame(width, height: height, elapsed: elapsed)
    }
    
    func onFirstRemoteVideoFrame(_ participant: RcvIParticipant?, width: Int32, height: Int32, elapsed: Int32) {
        delegate?.onFirstRemoteVideoFrame(participant, width: width, height: height, elapsed: elapsed)
    }
}
