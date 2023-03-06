//
//  EngineEventHandler.swift
//  RcvSwiftSample1v1meeting
//
//  Created by Yi Ke on 7/21/22.
//

import rcvsdk

class EngineEventHandler: RcvEngineEventHandler
{
    weak var delegate: RcvEngineEventHandler?
    
    init(delegate: RcvEngineEventHandler) {
        self.delegate = delegate
    }
    
    func onMeetingJoin(_ meetingId: String, errorCode: Int64) {
        self.delegate?.onMeetingJoin(meetingId, errorCode: errorCode)
    }
    
    func onMeetingLeave(_ meetingId: String, errorCode: Int64, reason: RcvLeaveReason) {
        self.delegate?.onMeetingLeave(meetingId, errorCode: errorCode, reason: reason)
    }
    
    func onPersonalMeetingSettingsUpdate(_ errorCode: Int64, settings: RcvPersonalMeetingSettings?) {
    }
    
    func onMeetingSchedule(_ errorCode: Int64, settings: RcvScheduleMeetingSettings?) {
    }
    
    func onAuthorization(_ newTokenJsonStr: String) {
    }
    
    func onAuthorizationError(_ errorCode: Int64) {
    }
    
    func onMeetingBridge(_ info: RcvMeetingBridgeInfo?) {
    }
}

