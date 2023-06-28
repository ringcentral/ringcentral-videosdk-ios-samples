//
//  MeetingUserEventHandler.swift
//  QuickStart
//
//  Created by Yi Ke on 11/11/22.
//

import rcvsdk

class MeetingUserEventHandler: RcvMeetingUserEventHandler
{
    func onCallOut(_ id: String, errorCode: Int64) {
        delegate?.onCallOut(id, errorCode: errorCode)
    }
    
    func onDeleteDial(_ errorCode: Int64) {
        delegate?.onDeleteDial(errorCode)
    }
    
    weak var delegate: RcvMeetingUserEventHandler?

    init(delegate: RcvMeetingUserEventHandler) {
        self.delegate = delegate
    }
    
    func onUserJoined(_ participant: RcvIParticipant?) {
        delegate?.onUserJoined(participant)
    }

    func onUserUpdated(_ participant: RcvIParticipant?) {
        delegate?.onUserUpdated(participant)
    }

    func onUserLeave(_ participant: RcvIParticipant?) {
        delegate?.onUserLeave(participant)
    }

    func onUserRoleChanged(_ participant: RcvIParticipant?) {
        delegate?.onUserRoleChanged(participant)
    }
    
    func onActiveSpeakerUserChanged(_ participant: RcvIParticipant?) {
        delegate?.onActiveSpeakerUserChanged(participant)
    }
    
    func onActiveVideoUserChanged(_ participant: RcvIParticipant?) {
        delegate?.onActiveVideoUserChanged(participant)
    }
    
    func onLocalNetworkQuality(_ state: RcvNqiState) {
        delegate?.onLocalNetworkQuality(state)
    }
    
    func onRemoteNetworkQuality(_ participant: RcvIParticipant?, state: RcvNqiState) {
        delegate?.onRemoteNetworkQuality(participant, state: state)
    }
}
