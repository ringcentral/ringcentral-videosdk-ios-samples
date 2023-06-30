//
//  CustomLayoutModel.swift
//  RCV-UIKit-Example
//
//  Created by Simon Xiang on 2023/6/26.
//

import UIKit
import rcvsdk

extension UIView {
    var width: CGFloat {
        get {
            return frame.size.width
        }

        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }

    var height: CGFloat {
        get {
            return frame.size.height
        }

        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    @discardableResult
    func makeConstraints(_ block: (UIView) -> [NSLayoutConstraint]) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(block(self))
        return self
    }

    @discardableResult
    func makeConstraintsToBindToSuperview(_ inset: UIEdgeInsets = .zero) -> Self {
        return makeConstraints { [
            $0.leftAnchor.constraint(equalTo: $0.superview!.leftAnchor, constant: inset.left),
            $0.rightAnchor.constraint(equalTo: $0.superview!.rightAnchor, constant: -inset.right),
            $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor, constant: inset.top),
            $0.bottomAnchor.constraint(equalTo: $0.superview!.bottomAnchor, constant: -inset.bottom),
        ] }
    }
    
    @discardableResult
    func makeConstraintsToLeftTop(width: CGFloat, height: CGFloat)-> Self {
        return makeConstraints { [
            $0.leftAnchor.constraint(equalTo: $0.superview!.leftAnchor),
            $0.rightAnchor.constraint(equalTo: $0.superview!.rightAnchor, constant: -(width/2)),
            $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor),
            $0.bottomAnchor.constraint(equalTo: $0.superview!.bottomAnchor, constant: (height/2)),
        ] }
    }
    
    @discardableResult
    func makeConstraintsToRightTop(width: CGFloat, height: CGFloat)-> Self {
        return makeConstraints { [
            $0.leftAnchor.constraint(equalTo: $0.superview!.leftAnchor, constant: (width/2)),
            $0.rightAnchor.constraint(equalTo: $0.superview!.rightAnchor),
            $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor),
            $0.bottomAnchor.constraint(equalTo: $0.superview!.bottomAnchor, constant: -(height/2)),
        ] }
    }
    
    @discardableResult
    func makeConstraintsToLeftBottom(width: CGFloat, height: CGFloat)-> Self {
        return makeConstraints { [
            $0.leftAnchor.constraint(equalTo: $0.superview!.leftAnchor),
            $0.rightAnchor.constraint(equalTo: $0.superview!.rightAnchor, constant: -(width/2)),
            $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor, constant: (height/2)),
            $0.bottomAnchor.constraint(equalTo: $0.superview!.bottomAnchor),
        ] }
    }
    
    @discardableResult
    func makeConstraintsToRightBottom(width: CGFloat, height: CGFloat)-> Self {
        return makeConstraints { [
            $0.leftAnchor.constraint(equalTo: $0.superview!.leftAnchor, constant: (width/2)),
            $0.rightAnchor.constraint(equalTo: $0.superview!.rightAnchor),
            $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor, constant: (height/2)),
            $0.bottomAnchor.constraint(equalTo: $0.superview!.bottomAnchor),
        ] }
    }
}

struct RemoteParticipantInfo {
    var isVideoMute: Bool = true
    var isAudioMute: Bool = true
    var participant: RcvIParticipant?
    
    init(participant: RcvIParticipant) {
        self.participant = participant
    }
}

class CustomLayoutModel {
    private var meetingID: String?
    private var meetingController: RcvMeetingController?
    var videoCanvasDict = Dictionary<Int64, RCVideoCanvas>()
    var localVideoCanvas: RCVideoCanvas?
    var activeVideoCanvas: RCVideoCanvas?
    
    @Published var participantsList: [RemoteParticipantInfo] = []
    @Published var perPageParticipants: [RemoteParticipantInfo] = []
    @Published var localVideoMute: Bool = false
    @Published var localAudioMute: Bool = false
    
    init(meetingID: String) {
        self.meetingID = meetingID
        
        self.meetingController = RcvEngine.instance().getMeetingController(meetingID)
        
        initParticioantsList()
        
        var me: RcvIParticipant?
        
        if let userController = self.meetingController?.getMeetingUserController() {
            me = userController.getMyself()
        }
        
        if let videoController = self.meetingController?.getVideoController() {
            let myUid = me?.getModelId()
            let localCanvas = RCVideoCanvas(view: nil, uid: myUid!)
            localCanvas?.setRenderMode(.fit)
            localCanvas?.setMirrorMode(true)
            self.localVideoCanvas = localCanvas
            
            self.localVideoMute = videoController.isMuted()
        }
        
        registerEvent()
    }
    
    deinit {
        unregisterEvent()
    }
    
    func getSubParticipants(beginIndex: Int, count: Int = 2) {
        var list: [RemoteParticipantInfo] = []
        var begin = beginIndex
        let end = min(begin+count, totalCount())
        while begin < end {
            list.append(self.participantsList[begin])
            
            begin = begin + 1
        }
        
        for elem in self.perPageParticipants {
            attachRemoteVideoView(participant: elem.participant!, view: nil)
        }
        
        self.perPageParticipants.removeAll()
        
        self.perPageParticipants = list
    }
    
    func getMySelf()-> RcvIParticipant? {
        if let userController = self.meetingController?.getMeetingUserController() {
            return userController.getMyself()
        }
        
        return nil
    }
    
    func attachLocalVideoView(view: UIView) {
        self.localVideoCanvas?.attach(view)
    }
    
    func attachRemoteVideoView(participant: RcvIParticipant, view: UIView?) {
        if participant.isMe() {
            return
        }
        
        guard let videoCanvas = videoCanvasDict[participant.getModelId()] else {
            return
        }
        
        videoCanvas.attach(view)
    }
    
    func totalCount()-> Int {
        return participantsList.count
    }
    
    func cellForRowAtIndex(index: Int)-> RcvIParticipant? {
        if participantsList.isEmpty || participantsList.count <= index {
            return nil
        }
        
        return participantsList[index].participant
    }
    
    private func initParticioantsList() {
        guard let meetingUserController = self.meetingController?.getMeetingUserController() else {
            return
        }
        
        let userList = meetingUserController.getMeetingUserList()
        for (_,value) in userList {
            if(value.status() != RcvEParticipantStatus.ACTIVE){
                continue
            }
            
            if !value.isMe() {
                let userUid = value.getModelId()
                if(self.videoCanvasDict[userUid] == nil){
                    let canvas = RCVideoCanvas(view: nil, uid: userUid)
                    canvas?.setRenderMode(.fit)
                    self.videoCanvasDict.updateValue(canvas!, forKey: userUid)
                }
                
                let retemoteInfo = RemoteParticipantInfo(participant: value)
                
                participantsList.append(retemoteInfo)
            }
        }
    }
    
    private func registerEvent() {
        self.meetingController?.register(self)
        
        if let userController = self.meetingController?.getMeetingUserController() {
            userController.register(self)
        }
        
        if let videoController = self.meetingController?.getVideoController() {
            videoController.register(self)
        }
        
        if let audioController = self.meetingController?.getAudioController() {
            audioController.register(self)
        }
    }
    
    private func unregisterEvent() {
        self.meetingController?.unregisterEventHandler(self)
        
        if let userController = self.meetingController?.getMeetingUserController() {
            userController.unregisterEventHandler(self)
        }
        
        if let videoController = self.meetingController?.getVideoController() {
            videoController.unregisterEventHandler(self)
        }
        
        if let audioController = self.meetingController?.getAudioController() {
            audioController.unregisterEventHandler(self)
        }
    }
    
    private func clearVideoCanvas() {
        guard let videoController = self.meetingController?.getVideoController() else {
            return
        }
        
        for participant in self.participantsList {
            let userUid = participant.participant!.getModelId()
            if let canvas = self.videoCanvasDict[userUid] {
                if(participant.participant!.isMe()){
                    //RCVVideoDataController.shared.removeLocalVideo()
                }
                else{
                    videoController.removeRemoteVideo(canvas)
                }
            }
        }
        
        self.participantsList.removeAll()
        self.videoCanvasDict.removeAll()
    }
    
    private func updateVideoCanvas(participant: RcvIParticipant) {
        guard let videoController = self.meetingController?.getVideoController() else {
            return
        }
        
        let canvas = RCVideoCanvas(view: nil, uid: participant.getModelId())
        canvas?.setRenderMode(.fit)
        self.videoCanvasDict.updateValue(canvas!, forKey: participant.getModelId())
        
        videoController.setupRemoteVideo(canvas!)
    }
    
    private func removeVideoCanvas(participant: RcvIParticipant) {
        self.videoCanvasDict.removeValue(forKey: participant.getModelId())
    }
    
    private func insertParticipantToSpeakerList(participant: RemoteParticipantInfo) {
        guard let index = self.participantsList.firstIndex(where: {
            $0.participant!.getModelId() == participant.participant!.getModelId()
        }) else {
            if participant.participant!.isMe() {
                return
            } else {
                self.participantsList.append(participant)
            }
            
            return
        }
        
        self.participantsList[index] = participant
    }
    
    private func removeParticipantFromSpeakerList(id: Int64) {
        self.participantsList.removeAll(where: {$0.participant!.getModelId() == id})
    }
    
    private func updateParticipantAudioMute(id: Int64, mute: Bool) {
        guard let index = self.participantsList.firstIndex(where: {
            $0.participant!.getModelId() == id
        }) else {
            return
        }
        
        self.participantsList[index].isAudioMute = mute
    }
    
    private func updateParticipantVideoMute(id: Int64, mute: Bool) {
        guard let index = self.participantsList.firstIndex(where: {
            $0.participant!.getModelId() == id
        }) else {
            return
        }
        
        self.participantsList[index].isVideoMute = mute
    }
    
    func setupVideoCanvas() {
        if let videoController = self.meetingController?.getVideoController() {
            for canvas in self.videoCanvasDict {
                videoController.setupRemoteVideo(canvas.value)
            }
            
            videoController.setupLocalVideo(self.localVideoCanvas)
        }
    }
    
    func removeVideoCanvas() {
        if let videoController = self.meetingController?.getVideoController() {
            for canvas in self.videoCanvasDict {
                videoController.removeRemoteVideo(canvas.value)
            }
            
            videoController.removeLocalVideo()
        }
    }
}

extension CustomLayoutModel: RcvMeetingEventHandler {
    func onMeetingStateChanged(_ state: RcvMeetingState) {
        return
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
    
    func onLiveTranscriptionHistoryChanged(_ data: [RcvLiveTranscriptionData]) {
        return
    }
}

extension CustomLayoutModel: RcvMeetingUserEventHandler {
    func onCallOut(_ id: String, errorCode: Int64) {
        
    }
    
    func onDeleteDial(_ errorCode: Int64) {
        
    }
    
    
    func onActiveSpeakerUserChanged(_ participant: RcvIParticipant?) {
     
    }

    func onActiveVideoUserChanged(_ participant: RcvIParticipant?) {
        return
    }

    func onUserJoined(_ participant: RcvIParticipant?) {
        if participant?.status() == .ACTIVE {
            self.updateVideoCanvas(participant: participant!)
            
            let remoteInfo = RemoteParticipantInfo(participant: participant!)
            self.insertParticipantToSpeakerList(participant: remoteInfo)
        }
    }

    func onUserUpdated(_ participant: RcvIParticipant?) {
        let status = participant?.status()
        
        if status == .ACTIVE {
            self.updateVideoCanvas(participant: participant!)
            let remoteInfo = RemoteParticipantInfo(participant: participant!)
            self.insertParticipantToSpeakerList(participant: remoteInfo)
        }
        else if status == .DISCONNECTED {
            self.removeVideoCanvas(participant: participant!)
            self.removeParticipantFromSpeakerList(id: participant!.getModelId())
        }
    }

    func onUserLeave(_ participant: RcvIParticipant?) {
        self.removeVideoCanvas(participant: participant!)
        self.removeParticipantFromSpeakerList(id: participant!.getModelId())
    }
    
    func onUserRoleChanged(_ participant: RcvIParticipant?) {
        
    }

    func onLocalNetworkQuality(_ state: RcvNqiState) {
        
    }

    func onRemoteNetworkQuality(_ participant: RcvIParticipant?, state: RcvNqiState) {
        
    }
}

extension CustomLayoutModel: RcvVideoEventHandler {
    func onLocalVideoMuteChanged(_ muted: Bool) {
        self.localVideoMute = muted
    }
    
    func onRemoteVideoMuteChanged(_ participant: RcvIParticipant?, muted: Bool) {
        updateParticipantVideoMute(id: participant!.getModelId(), mute: muted)
    }
    
    func onUnmuteVideoDemand() {
        
    }
    
    func onFirstLocalVideoFrame(_ width: Int32, height: Int32, elapsed: Int32) {
        return
    }
    
    func onFirstRemoteVideoFrame(_ participant: RcvIParticipant?, width: Int32, height: Int32, elapsed: Int32) {
        return
    }
}

extension CustomLayoutModel: RcvAudioEventHandler {
    func onLocalAudioStreamStateChanged(_ state: RcvLocalAudioStreamState, error: RcvLocalAudioError) {
        
    }
    
    func onLocalAudioMuteChanged(_ muted: Bool) {
        self.localAudioMute = muted
    }
    
    func onRemoteAudioMuteChanged(_ participant: RcvIParticipant?, muted: Bool) {
        updateParticipantAudioMute(id: participant!.getModelId(), mute: muted)
    }
    
    func onUnmuteAudioDemand() {
        
    }
    
    func onAudioRouteChanged(_ audioRouteType: RcvAudioRouteType) {
        
    }
}
