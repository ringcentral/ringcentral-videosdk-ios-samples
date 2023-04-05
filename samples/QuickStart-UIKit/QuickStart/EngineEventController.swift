//
//  EngineEventController.swift
//  RCV-UIKit-Example
//
//  Created by Simon Xiang on 2023/3/24.
//

import rcvsdk

class EngineEventController: RcvEngineEventHandler
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

class MeetingEventController: RcvMeetingEventHandler {
    weak var delegate: RcvMeetingEventHandler?
    
    init(delegate: RcvMeetingEventHandler) {
        self.delegate = delegate
    }
    
    func onMeetingStateChanged(_ state: RcvMeetingState) {
        self.delegate?.onMeetingStateChanged(state)
    }
    
    func onRecordingStateChanged(_ state: RcvRecordingState) {
        return
    }
    
    func onRecordingAllowChanged(_ allowed: Bool) {
        return
    }
    
    func onMeetingApiExecuted(_ method: String, errorCode: Int64, result: RcvMeetingApiExecuteResult) {
        return
    }
    
    func onMeetingLockStateChanged(_ locked: Bool) {
        return
    }
    
    func onMeetingEncryptionStateChanged(_ state: RcvEndToEndEncryptionState) {
        return
    }
    
    func onChatMessageSend(_ messageId: Int32, errorCode: Int64) {
        return
    }
    
    func onChatMessageReceived(_ meetingChatMessage: [RcvMeetingChatMessage]) {
        return
    }
    
    func onClosedCaptionsData(_ data: [RcvClosedCaptionsData]) {
        return
    }
    
    func onClosedCaptionsStateChanged(_ state: RcvClosedCaptionsState) {
        return
    }
    
    func onLiveTranscriptionDataChanged(_ data: RcvLiveTranscriptionData?, type: RcvLiveTranscriptionDataType) {
        return
    }
    
    func onLiveTranscriptionSettingChanged(_ data: RcvLiveTranscriptionSetting?) {
        return
    }
    
    func onLiveTranscriptionHistoryChanged(_ data: [RcvLiveTranscriptionData], type: RcvLiveTranscriptionUpdateHistoryType) {
        return
    }
}
