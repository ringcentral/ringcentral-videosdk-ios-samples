//
//  MeetingEventHandler.swift
//  RcvSwiftSample1v1meeting
//
//  Created by Yi Ke on 7/21/22.
//

import rcvsdk

class MeetingEventHandler: RcvMeetingEventHandler
{
    func onLiveTranscriptionDataChanged(_ data: RcvLiveTranscriptionData?, type: RcvLiveTranscriptionDataType) {
        
    }
    
    func onLiveTranscriptionSettingChanged(_ data: RcvLiveTranscriptionSetting?) {
        
    }
    
    func onLiveTranscriptionHistoryChanged(_ data: [RcvLiveTranscriptionData]) {
        
    }
    
    weak var delegate: RcvMeetingEventHandler?

    init(delegate: RcvMeetingEventHandler) {
        self.delegate = delegate
    }

    func onRecordingStateChanged(_ state: RcvRecordingState) {
        delegate?.onRecordingStateChanged(state)
    }

    func onMeetingApiExecuted(_ method: String, errorCode: Int64, result: RcvMeetingApiExecuteResult) {
        delegate?.onMeetingApiExecuted(method, errorCode: errorCode, result: result)
    }

    func onMeetingLockStateChanged(_ locked: Bool) {
        delegate?.onMeetingLockStateChanged(locked)
    }
    
    func onChatMessageSend(_ messageId: Int32, errorCode: Int64) {
    }
    
    func onChatMessageReceived(_ meetingChatMessage: [RcvMeetingChatMessage]) {
    }
    
    func onMeetingEncryptionStateChanged(_ state: RcvEndToEndEncryptionState) {
    }
    
    func onMeetingStateChanged(_ state: RcvMeetingState) {
    }
    
    func onRecordingAllowChanged(_ allowed: Bool) {
    }
    
    func onClosedCaptionsData(_ data: [RcvClosedCaptionsData]) {
    }
    
    func onClosedCaptionsStateChanged(_ state: RcvClosedCaptionsState) {
    }
}
