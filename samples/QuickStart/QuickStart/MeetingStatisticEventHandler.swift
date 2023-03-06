//
//  MeetingStatisticEventHandler.swift
//  QuickStart
//
//  Created by Yi Ke on 11/11/22.
//

import rcvsdk

class MeetingStatisticEventHandler: RcvMeetingStatisticEventHandler
{
    weak var delegate: RcvMeetingStatisticEventHandler?
    
    init(delegate: RcvMeetingStatisticEventHandler) {
        self.delegate = delegate
    }
    
    func onLocalAudioStats(_ stats: RcvLocalAudioStats?) {
        delegate?.onLocalAudioStats(stats)
    }
    
    func onLocalVideoStats(_ stats: RcvLocalVideoStats?) {
        delegate?.onLocalVideoStats(stats)
    }
    
    func onRemoteAudioStats(_ stats: RcvRemoteAudioStats?) {
        delegate?.onRemoteAudioStats(stats)
    }
    
    func onRemoteVideoStats(_ stats: RcvRemoteVideoStats?) {
        delegate?.onRemoteVideoStats(stats)
    }
}
