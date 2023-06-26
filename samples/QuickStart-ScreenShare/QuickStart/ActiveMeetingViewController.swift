//
//  ActiveMeetingViewController.swift
//  RcvSwiftSampleMeeting
//
//  Created by Yi Ke on 7/22/22.
//  Modifyed by Simon Xiang on 2/9/2023.

import UIKit
import rcvsdk
import AVFAudio
import ReplayKit


class ActiveMeetingViewController: UIViewController {
    
    public var meetingId: String?
    
    var hideBarTimer: Timer?
    var durationTimer: Timer?
    var overTimeCount: Int = 0
    
    private let meetingIdLabel = UILabel()
    
    private var meetingEventHandler: RcvMeetingEventHandler?
    public var meetingUserEventHandler: RcvMeetingUserEventHandler?
    private var meetingStatisticEventHandler: RcvMeetingStatisticEventHandler?
    private var audioEventHandler: RcvAudioEventHandler?
    private var videoEventHandler: RcvVideoEventHandler?
    private var participants = [RcvIParticipant]()
    
    private(set) var meetingInfoView: RCVMeetingDetailInfoViewProtocol?

    private var backBlurView: RCVMeetingBlurView?
    
    let toolbarDatasource = RCVToolBarDataSource()
    
    lazy var layoutManager = RCVMeetingLayoutManager()
    
    lazy var bottomToolbar: RCVMeetingToolbar = { [weak self] in
        let toolbar = RCVMeetingToolbar(frame: .zero)
        toolbar.accessibilityIdentifier = "MeetingBottomBar"
        toolbar.bubbleDirection = .down

        return toolbar
    }()
    
    lazy var topToolbar: RCVMeetingToolbar = { [weak self] in
        let toolbar = RCVMeetingToolbar(frame: .zero)
        toolbar.accessibilityIdentifier = "MeetingTopBar"
        toolbar.bubbleDirection = .down

        return toolbar
    }()
    
    lazy var galleryContainerViewController: RCVMeetingGalleryContainerViewController = {
        let vc = RCVMeetingGalleryContainerViewController()
        return vc
    }()
    
    private var participantViewDelegate: RCVParticipantListViewDelegate?
    
    private lazy var transitionManager = RCVTransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        view.backgroundColor = RCVColor.get(.neutralB05)
        
        configBlurBcakground()
        configTopBar()
        configBottomBar()
        configMeetingIdLabel()
        checkMicPermission()
        
        layoutManager.delegate = self
        onJoinMeetingSuccess()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        self.view.makeConstraintsToBindToSuperview()
        updateMeetingIdLabel()
        updateToolBars()
    }
    
    private func configAudioButtonInitialIcon(permissionStatus: AVAudioSession.RecordPermission) {
        let type: MuteState = (permissionStatus == .granted) ? .unMute : .mute
        toolbarDatasource.audioViewModel.itemType = .mute(type)
        bottomToolbar.reloadToolItems(item: toolbarDatasource.audioViewModel)
        topToolbar.reloadToolItems(item: toolbarDatasource.audioViewModel)
    }
    
    private func isInternetAudio() -> Bool {
        let audioController = RCVMeetingDataSource.getAudioController()
        let audioState = audioController?.getLocalAudioStreamState()
        
        if audioState == .localAudioStreamStateStarted {
            return true
        } else {
            return false
        }
    }
    
    private func checkMicPermission() {
        let permission = AVAudioSession.sharedInstance().recordPermission
        self.configAudioButtonInitialIcon(permissionStatus: permission)
    }
    
    private func updateToolBars() {
        let perssion = RCVMeetingDataSource.isHostOrModerator()
        toolbarDatasource.leaveViewModel.itemType = .leave(hasEndPermission: perssion)
        
        let speakerPhoneType = RCVMeetingDataSource.getCurrentSpeakerPhoneType()
        toolbarDatasource.speakerViewModel.state = .normal
        switch speakerPhoneType {
        case .phone:
            toolbarDatasource.speakerViewModel.itemType = .audioChannel(.iPhone)
        case .speaker:
            toolbarDatasource.speakerViewModel.itemType = .audioChannel(.speaker)
        case .bluetooth:
            toolbarDatasource.speakerViewModel.itemType = .audioChannel(.bluetooth)
        }
        
        let audioMute = RCVMeetingDataSource.getAudioController()?.isMuted()
        let audiotype: MuteState = audioMute! ? .mute : .unMute
        toolbarDatasource.audioViewModel.itemType = .mute(audiotype)
        
        let videoMute = RCVMeetingDataSource.getVideoController()?.isMuted()
        let videoType: VideoState = videoMute! ? .stop : .start
        toolbarDatasource.videoViewModel.itemType = .video(videoType)
        
        topToolbar.toolbarItems = [
            toolbarDatasource.speakerViewModel,
            toolbarDatasource.meetingInfoViewModel,
            toolbarDatasource.leaveViewModel,
        ].compactMap { $0 }
        
        bottomToolbar.toolbarItems = [toolbarDatasource.audioViewModel,
                                      toolbarDatasource.videoViewModel,
                                      toolbarDatasource.participantViewModel,
                                      toolbarDatasource.shareScreenViewModel].compactMap { $0 }
    }
    
    private func configBlurBcakground() {
        let blurView = RCVMeetingBlurView(frame: view.bounds)
        view.addSubview(blurView)
        blurView.setupDefaultImages()
        blurView.makeConstraintsToBindToSuperview()
        backBlurView = blurView
    }
    
    private func configTopBar() {
        view.addSubview(topToolbar)
        topToolbar.isHidden = false
        topToolbar.translatesAutoresizingMaskIntoConstraints = false
        topToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        topToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        topToolbar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topToolbar.delegate = self
    }
    
    private func configBottomBar() {
        view.addSubview(bottomToolbar)
        bottomToolbar.isHidden = false
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        bottomToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        bottomToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        bottomToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomToolbar.delegate = self
    }
    
    private func configMeetingIdLabel() {
        let topBarView = self.topToolbar
        topBarView.addSubview(meetingIdLabel)
        
        let horizontalStackView = topBarView.horizontalStackView
        
        meetingIdLabel.translatesAutoresizingMaskIntoConstraints = false
        meetingIdLabel.textColor = RCVColor.get(.avatarAsh)
        meetingIdLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        NSLayoutConstraint.activate([
            meetingIdLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),
            meetingIdLabel.bottomAnchor.constraint(equalTo: horizontalStackView.topAnchor),
        ])
        
    }
    
    private func updateMeetingIdLabel() {
        meetingIdLabel.text = "Meeting ID:" + self.meetingId!
    }
    
    func getSubVC(from type: RCVMeetingLayoutType) -> UIViewController {
        switch type {
        case .Gallery:
            return galleryContainerViewController
        }
    }
    
    public func onJoinMeetingSuccess() {
        updateLayout()
        OverlayWindowManager.shared.overlayWindow.isHidden = false
    }
    
    private func updateLayout() {
        layoutManager.delegate = self
        layoutManager.updateLayout(layout: .Gallery)
    }
    
    public func updateAudioRouteView() {
        let speakerPhoneType = RCVMeetingDataSource.getCurrentSpeakerPhoneType()
        
        toolbarDatasource.speakerViewModel.state = .normal
        
        switch speakerPhoneType {
        case .phone:
            toolbarDatasource.speakerViewModel.itemType = .audioChannel(.iPhone)
        case .speaker:
            toolbarDatasource.speakerViewModel.itemType = .audioChannel(.speaker)
        case .bluetooth:
            toolbarDatasource.speakerViewModel.itemType = .audioChannel(.bluetooth)
        }
        
        topToolbar.reloadToolItems(item: toolbarDatasource.speakerViewModel)
    }
    
    public func updateVideoButtonView() {
        let videoMute = RCVMeetingDataSource.getCurrentVideoMute()
        
        toolbarDatasource.videoViewModel.state = .normal
        
        if(videoMute){
            toolbarDatasource.videoViewModel.itemType = .video(.stop)
        }
        else{
            toolbarDatasource.videoViewModel.itemType = .video(.start)
        }
        
        bottomToolbar.reloadToolItems(item: toolbarDatasource.videoViewModel)
    }

    
    private func isLargeToolBarMode() -> Bool {
        return RCVMeetingDataSource.isIPhoneLandscapeOrRegularWidth(traitCollection: traitCollection)
    }
    
    private func leaveMeeting() {
        RCVMeetingDataSource.clearParticipants()
        
        participants.removeAll()
        let meetingController = RCVMeetingDataSource.getMeetingController()
        self.galleryContainerViewController.mainGalleryViewController.videoCanvasDict.removeAll()
        meetingController?.leaveMeeting()
    }
        
    lazy var broadcastPicker: UIView = {
        #if arch(i386) || arch(x86_64)
            return UIView()
        #else
            var broadcastPicker: RPSystemBroadcastPickerView = RPSystemBroadcastPickerView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 64, height: 64)))
            broadcastPicker.showsMicrophoneButton = false
            broadcastPicker.accessibilityViewIsModal = true
            if #available(iOS 12.2, *) {
                broadcastPicker.preferredExtension = "com.ringcentral.video.quickstart.QuickStartBroadcast"
            }
            return broadcastPicker
        #endif
    }()
    
    private var workItem: DispatchWorkItem?

    private func debounce(_ duration: TimeInterval, block: @escaping () -> Void) {
        workItem?.cancel()
        let item = DispatchWorkItem(block: block)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: item)
        workItem = item
    }
    
    func startSharing() {
        debounce(0.3) { [weak self] in
            self?._startSharing()
        }
    }

    func _startSharing() {
        if let childButton = broadcastPicker.subviews.first(where: { $0 is UIControl }) as? UIControl {
            if #available(iOS 13, *) {
                childButton.sendActions(for: .touchUpInside)
            } else {
                childButton.sendActions(for: .touchDown)
            }
        }
    }
    
    private func endMeeting() {
        RCVMeetingDataSource.clearParticipants()
        
        participants.removeAll()
        let meetingController = RCVMeetingDataSource.getMeetingController()
        self.galleryContainerViewController.mainGalleryViewController.videoCanvasDict.removeAll()
        meetingController?.endMeeting()
    }

    
    private func setupVideoCanvas() {
        guard let meetingUserController = RCVMeetingDataSource.getMeetingUserController() else {
            return
        }
        let userList = meetingUserController.getMeetingUserList()
        for (_,value) in userList {
            if(value.status() != RcvEParticipantStatus.ACTIVE){
                continue
            }
            participants.append(value)
        }

        self.galleryContainerViewController.reloadPageData(participants)
        
        for user in participants {
            let userUid = user.getModelId()
            if(self.galleryContainerViewController.mainGalleryViewController.videoCanvasDict[userUid] == nil){
                let canvas = RCVideoCanvas(view: nil, uid: userUid)
                canvas?.setRenderMode(.fit)
                self.galleryContainerViewController.mainGalleryViewController.videoCanvasDict.updateValue(canvas!, forKey: userUid)
                guard let videoController = RCVMeetingDataSource.getVideoController() else {
                    return
                }
                if(user.isMe()){
                    videoController.setupLocalVideo(canvas)
                }
                else{
                    videoController.setupRemoteVideo(canvas)
                }
            }
        }
    }
    
    private func sendTimeStrToListener(displayTime: String) {
        meetingInfoView?.setMeetingDuration(duration: displayTime)
    }
    
    private func getDurationString(for duration: Int) -> String {
        let hourNum = duration / 3600
        let durationString: String
        if hourNum == 0 {
            durationString = String(format: "%02d:%02d", duration / 60, overTimeCount % 60)
        } else {
            durationString = String(format: "%02d:%02d:%02d", hourNum, (duration - 3600 * hourNum) / 60, (duration - 3600 * hourNum) % 60)
        }
        return durationString
    }
    
    private func updateTitleViewDuration() {
        overTimeCount += 1
        let overTimeString = getDurationString(for: overTimeCount)
        sendTimeStrToListener(displayTime: overTimeString)
    }
    
    private func invalidateDurationTimer() {
        if durationTimer != nil {
            durationTimer?.invalidate()
            durationTimer = nil
            overTimeCount = 0
        }
    }
    
    private func addDurationTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            self?.updateTitleViewDuration()
        })
        RunLoop.current.add(timer, forMode: .common)
        durationTimer = timer
    }
    
    func onMeetingJoin(_ meetingId: String, errorCode: Int64) {
        self.meetingId = meetingId
        
        RCVMeetingDataSource.setMeetingId(id: meetingId)
        RCVMeetingDataSource.clearParticipants()
        let userController = RCVMeetingDataSource.getMeetingUserController()
        let participantList = userController?.getMeetingUserList()
        for (_, elem) in participantList! {
            let status = elem.status()
            switch status {
            case .ACTIVE:
                RCVMeetingDataSource.insertParticipantToActiveList(participant: elem)
                RCVMeetingDataSource.insertParticipantToList(participant: elem)
            case .INWAITINGROOM:
                RCVMeetingDataSource.insertParticipantToInWaitRoomList(participant: elem)
            case .DISCONNECTED:
                RCVMeetingDataSource.insertParticipantToDisconnectList(participant: elem)
            default:
                break
            }
        }
        
        addDurationTimer()
        registerEventHandlers()
        setupVideoCanvas()
    }
    
    func onMeetingLeave(_ meetingId: String, errorCode: Int64, reason: RcvLeaveReason) {
        self.meetingId = ""
    
        unregisterEventHandlers()
        RCVMeetingDataSource.clearData()
        invalidateDurationTimer()
    }
    
    func registerEventHandlers() {
        self.meetingEventHandler = MeetingEventHandler(delegate: self)
        self.meetingUserEventHandler = MeetingUserEventHandler(delegate: self)
        self.meetingStatisticEventHandler = MeetingStatisticEventHandler(delegate: self)
        self.audioEventHandler = AudioEventHandler(delegate: self)
        self.videoEventHandler = VideoEventHandler(delegate: self)
    
        guard let meetingController = RCVMeetingDataSource.getMeetingController() else {
                return
            }
            meetingController.register(self.meetingEventHandler)
            meetingController.register(self.meetingStatisticEventHandler)
    
        guard let meetingUserController = RCVMeetingDataSource.getMeetingUserController() else {
                return
            }
            meetingUserController.register(self.meetingUserEventHandler)
        
        guard let audioController = RCVMeetingDataSource.getAudioController() else {
                return
            }
            audioController.register(self.audioEventHandler)
    
        guard let videoController = RCVMeetingDataSource.getVideoController() else {
                return
            }
            videoController.register(self.videoEventHandler)
    }
    
    func unregisterEventHandlers() {
        guard let meetingController = RCVMeetingDataSource.getMeetingController() else {
            return
        }
        meetingController.unregisterEventHandler(self.meetingEventHandler)

        guard let audioController = RCVMeetingDataSource.getAudioController() else {
            return
        }
        audioController.unregisterEventHandler(self.audioEventHandler)

        guard let videoController = RCVMeetingDataSource.getVideoController() else {
            return
        }
        videoController.unregisterEventHandler(self.videoEventHandler)
    }
    
    func updateParticipants(with participant: RcvIParticipant){
        for user in participants {
            if(user.displayName() == participant.displayName()){
                let index = participants.firstIndex(of: user)
                participants[index!] = participant
                return
            }
        }
    }
}


extension ActiveMeetingViewController: RcvMeetingEventHandler {
    func onLiveTranscriptionDataChanged(_ data: RcvLiveTranscriptionData?, type: RcvLiveTranscriptionDataType) {
        return
    }
    
    func onLiveTranscriptionSettingChanged(_ data: RcvLiveTranscriptionSetting?) {
        return
    }
    
    func onLiveTranscriptionHistoryChanged(_ data: [RcvLiveTranscriptionData]) {
        return
    }
    
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
}


extension ActiveMeetingViewController: RcvMeetingUserEventHandler {
    
    func onActiveSpeakerUserChanged(_ participant: RcvIParticipant?) {
    }

    func onActiveVideoUserChanged(_ participant: RcvIParticipant?) {
    }

    func onUserJoined(_ participant: RcvIParticipant?) {
        let status = participant?.status()
        RCVMeetingDataSource.removeParticipantFromActiveList(participant: participant!)
        RCVMeetingDataSource.removeParticipantFromList(participant: participant!)
        RCVMeetingDataSource.removeParticipantFromDisconnectList(participant: participant!)
        RCVMeetingDataSource.removeParticipantFromInWaitRoomList(participant: participant!)
        
        switch status {
        case .ACTIVE:
            RCVMeetingDataSource.insertParticipantToActiveList(participant: participant!)
            RCVMeetingDataSource.insertParticipantToList(participant: participant!)
            
            self.galleryContainerViewController.reloadPageData(RCVMeetingDataSource.getActiveParticipantsList())
            let canvas = RCVideoCanvas(view: nil, uid: participant!.getModelId())
            canvas?.setRenderMode(.fit)
            self.galleryContainerViewController.mainGalleryViewController.videoCanvasDict.updateValue(canvas!, forKey: participant!.getModelId())
            guard let videoController = RCVMeetingDataSource.getVideoController() else {
                return
            }
            videoController.setupRemoteVideo(canvas)
        case .INWAITINGROOM:
            RCVMeetingDataSource.insertParticipantToInWaitRoomList(participant: participant!)
        default:
            break
        }
        
        self.participantViewDelegate?.updateParticipantListViewSection()
        
        for user in participants {
            if(user.displayName() == participant?.displayName())
            {
                return
            }
        }
        self.participants.append(participant!)
        self.galleryContainerViewController.reloadPageData(participants)
        
        let canvas = RCVideoCanvas(view: nil, uid: participant!.getModelId())
        canvas?.setRenderMode(.fit)
        self.galleryContainerViewController.mainGalleryViewController.videoCanvasDict.updateValue(canvas!, forKey: participant!.getModelId())

        guard let videoController = RCVMeetingDataSource.getVideoController() else {
            return
        }
        videoController.setupRemoteVideo(canvas)
    }

    func onUserUpdated(_ participant: RcvIParticipant?) {
        RCVMeetingDataSource.removeParticipantFromActiveList(participant: participant!)
        RCVMeetingDataSource.removeParticipantFromList(participant: participant!)
        RCVMeetingDataSource.removeParticipantFromDisconnectList(participant: participant!)
        RCVMeetingDataSource.removeParticipantFromInWaitRoomList(participant: participant!)
        let status = participant?.status()
        switch status {
        case .ACTIVE:
            RCVMeetingDataSource.insertParticipantToActiveList(participant: participant!)
            RCVMeetingDataSource.insertParticipantToList(participant: participant!)
            
            self.galleryContainerViewController.reloadPageData(RCVMeetingDataSource.getActiveParticipantsList())
            let canvas = RCVideoCanvas(view: nil, uid: participant!.getModelId())
            canvas?.setRenderMode(.fit)
            self.galleryContainerViewController.mainGalleryViewController.videoCanvasDict.updateValue(canvas!, forKey: participant!.getModelId())
            guard let videoController = RCVMeetingDataSource.getVideoController() else {
                return
            }
            videoController.setupRemoteVideo(canvas)
        case .DISCONNECTED:
            RCVMeetingDataSource.insertParticipantToDisconnectList(participant: participant!)
            
            self.galleryContainerViewController.reloadPageData(RCVMeetingDataSource.getActiveParticipantsList())
        case .INWAITINGROOM:
            RCVMeetingDataSource.insertParticipantToInWaitRoomList(participant: participant!)
        default:
            break
        }

        self.participantViewDelegate?.updateParticipantListViewSection()

        if(participant!.status() == RcvEParticipantStatus.DISCONNECTED){
            self.participants = self.participants.filter{$0 != participant}
            self.galleryContainerViewController.reloadPageData(participants)
        }
        else{
            for user in participants {
                if(user.displayName() == participant?.displayName())
                {
                    return
                }
            }
            self.participants.append(participant!)
            self.galleryContainerViewController.reloadPageData(participants)
        }
    }

    func onUserLeave(_ participant: RcvIParticipant?) {
        self.participants = self.participants.filter{$0 != participant}
        self.galleryContainerViewController.reloadPageData(participants)
        return
    }
    
    func onUserRoleChanged(_ participant: RcvIParticipant?) {
        RCVMeetingDataSource.removeParticipantFromActiveList(participant: participant!)
        RCVMeetingDataSource.removeParticipantFromList(participant: participant!)
        RCVMeetingDataSource.removeParticipantFromDisconnectList(participant: participant!)
        RCVMeetingDataSource.removeParticipantFromInWaitRoomList(participant: participant!)
        
        let status = participant?.status()
        switch status {
        case .ACTIVE:
            RCVMeetingDataSource.insertParticipantToActiveList(participant: participant!)
            RCVMeetingDataSource.insertParticipantToList(participant: participant!)
        case .DISCONNECTED:
            RCVMeetingDataSource.insertParticipantToDisconnectList(participant: participant!)
        case .INWAITINGROOM:
            RCVMeetingDataSource.insertParticipantToInWaitRoomList(participant: participant!)
        default:
            break
        }
        self.participantViewDelegate?.updateParticipantListViewSection()
    }

    func onLocalNetworkQuality(_ state: RcvNqiState) {
        self.galleryContainerViewController.reloadPageData(participants)
        self.participantViewDelegate?.updateParticipantListViewSection()
    }

    func onRemoteNetworkQuality(_ participant: RcvIParticipant?, state: RcvNqiState) {
        self.galleryContainerViewController.reloadPageData(participants)
        self.participantViewDelegate?.updateParticipantListViewSection()
    }
}


extension ActiveMeetingViewController: RcvMeetingStatisticEventHandler {
    func onLocalAudioStats(_ stats: RcvLocalAudioStats?) {
        return
    }
    
    func onLocalVideoStats(_ stats: RcvLocalVideoStats?) {
        return
    }
    
    func onRemoteAudioStats(_ stats: RcvRemoteAudioStats?) {
        return
    }
    
    func onRemoteVideoStats(_ stats: RcvRemoteVideoStats?) {
        return
    }
}


extension ActiveMeetingViewController: RcvAudioEventHandler {
    func onLocalAudioStreamStateChanged(_ state: RcvLocalAudioStreamState, error: RcvLocalAudioError) {
        return
    }
    
    func onLocalAudioMuteChanged(_ muted: Bool) {
        let type: MuteState = muted ? .mute : .unMute
        toolbarDatasource.audioViewModel.itemType = .mute(type)
        bottomToolbar.reloadToolItems(item: toolbarDatasource.audioViewModel)
        topToolbar.reloadToolItems(item: toolbarDatasource.audioViewModel)
        
        let me = RCVMeetingDataSource.getMeetingUserController()?.getMyself()
        RCVMeetingDataSource.updateParticipantInList(participant: me!)
        self.participantViewDelegate?.updateParticipantListViewSection()
        updateParticipants(with: me!)
        self.galleryContainerViewController.reloadPageData(participants)
    }
    
    func onRemoteAudioMuteChanged(_ participant: RcvIParticipant?, muted: Bool) {
        RCVMeetingDataSource.updateParticipantInList(participant: participant!)
        self.participantViewDelegate?.updateParticipantListViewSection()
        updateParticipants(with: participant!)
        self.galleryContainerViewController.reloadPageData(participants)
    }
    
    func onUnmuteAudioDemand() {
        let title = "Allow Host to Unmute You?"
        
        let allowAction = RCVMeetingAlertAction(title: "Allow", style: .default) {
            _ in
            let audioController = RCVMeetingDataSource.getAudioController()
            audioController?.unmuteLocalAudioStream()
        }
        
        let cancelAction = RCVMeetingAlertAction(title: "Don't Allow", style: .default, handler: { _ in })
        
        RCVMeetingAlertManager.sharedInstance.showAlertOfTitle(title, text: nil, style: .alert, actions: [allowAction, cancelAction], viewController: self, additionObject: nil, completion: nil)
    }
    
    func onAudioRouteChanged(_ audioRouteType: RcvAudioRouteType) {
        RCVMeetingDataSource.updateSpeakerPhoneType(audioRouteType)
        
        self.updateAudioRouteView()
        
        return
    }
}


extension ActiveMeetingViewController: RcvVideoEventHandler {
    func onLocalVideoMuteChanged(_ muted: Bool) {
        RCVMeetingDataSource.updateVideoMuteStatus(muted)
        self.updateVideoButtonView()
        
        let me = RCVMeetingDataSource.getMeetingUserController()?.getMyself()
        RCVMeetingDataSource.updateParticipantInList(participant: me!)
        self.participantViewDelegate?.updateParticipantListViewSection()
        self.galleryContainerViewController.reloadPageData(participants)
        return
    }
    
    func onRemoteVideoMuteChanged(_ participant: RcvIParticipant?, muted: Bool) {
        RCVMeetingDataSource.updateParticipantInList(participant: participant!)
        self.participantViewDelegate?.updateParticipantListViewSection()
    }
    
    func onUnmuteVideoDemand() {
        let title = "Allow Host to enable your video?"
        
        let allowAction = RCVMeetingAlertAction(title: "Allow", style: .default) {
            _ in
            let videoController = RCVMeetingDataSource.getVideoController()
            videoController?.unmuteLocalVideoStream()
        }
        
        let cancelAction = RCVMeetingAlertAction(title: "Don't Allow", style: .default, handler: { _ in })
        
        RCVMeetingAlertManager.sharedInstance.showAlertOfTitle(title, text: nil, style: .alert, actions: [allowAction, cancelAction], viewController: self, additionObject: nil, completion: nil)
    }
    
    func onFirstLocalVideoFrame(_ width: Int32, height: Int32, elapsed: Int32) {
        return
    }
    
    func onFirstRemoteVideoFrame(_ participant: RcvIParticipant?, width: Int32, height: Int32, elapsed: Int32) {
        return
    }
}


extension ActiveMeetingViewController: RCVLayoutChangeDelegate {
    func layoutDidChanged(from oldLayout: RCVMeetingLayoutType, to newLayout: RCVMeetingLayoutType) {
        updateMeetingLayout(from: oldLayout, to: newLayout)
    }
    
    func updateMeetingLayout(from oldLayout: RCVMeetingLayoutType, to newLayout: RCVMeetingLayoutType) {
        let layoutVC = getSubVC(from: newLayout)
        
        addChild(layoutVC)
        view.addSubview(layoutVC.view)
        layoutVC.view.backgroundColor = .clear
        layoutVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        layoutVC.view.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        layoutVC.view.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        layoutVC.view.topAnchor.constraint(equalTo: topToolbar.bottomAnchor, constant: 0).isActive = true
        layoutVC.view.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor, constant: 0).isActive = true
        
        layoutVC.view.isHidden = false
        layoutVC.didMove(toParent: self)
    }
    
    func onParticipantsListChange() {
        self.galleryContainerViewController.onParticipantsListUpdate()
    }
}


extension ActiveMeetingViewController: RCVMeetingToolbarDelegate {
    func didSelectToolbarItem(_ item: RCVToolBarItem?) {
        if item?.state == .disable {
            return
        }
        handleSelectToolbarItemAction(item)
    }
    
    private func handleSelectToolbarItemAction(_ item: RCVToolBarItem?) {
        guard let type = item?.itemType else {
            return
        }
        
        switch type {
        case .mute:
            audioMuteBtnAction()
        case .video:
            updateVideoStatus()
            break
        case .audioChannel:
            changeAudioRoute()
        case .chat: break
        case .leave:
            meetingLeaveBtnAction()
        case .screenShare:
            sceenShareBtnAction()
        case .audio: break
        case .participant:
            participantBtnAction()
        case .meetingInfo:
            meetingInfoBtnAction()
        case .networkState:
            networkStateBtnAction()
        }
    }
    
    private func updateVideoStatus() {
        guard let meetingController = RCVMeetingDataSource.getMeetingController() else {
            return
        }
        
        guard let videoController = meetingController.getVideoController() else {
            return
        }
        
        if (videoController.isMuted()) {
            videoController.unmuteLocalVideoStream()
        } else {
            videoController.muteLocalVideoStream()
        }
    }
    
    private func networkStateBtnAction() {
        
    }
    
    private func audioMuteBtnAction() {
        let audioController = RCVMeetingDataSource.getAudioController()
        
        if audioController?.isMuted() == true {
            audioController?.unmuteLocalAudioStream()
        } else {
            audioController?.muteLocalAudioStream()
        }
    }
    
    private func changeAudioRoute() {
        let audioController = RCVMeetingDataSource.getAudioController()
        
        let spekaerPhoneType = RCVMeetingDataSource.getCurrentSpeakerPhoneType()
        
        if spekaerPhoneType == .speaker {
            audioController?.disableSpeakerphone()
        } else {
            audioController?.enableSpeakerphone()
        }
    }
    
    private func meetingInfoBtnAction() {
        let meetingInfoView : RCVMeetingDetailInfoView
        if let mv = self.meetingInfoView {
            meetingInfoView = mv as! RCVMeetingDetailInfoView
        } else {
            meetingInfoView = RCVMeetingDetailInfoView()
            self.meetingInfoView = meetingInfoView
        }
        
        meetingInfoView.style = isLargeToolBarMode() ? .fixWidth : .fullWidth
        meetingInfoView.updatePopupTopSpacing(topToolbar.height - view.safeAreaInsets.top + 4)
        meetingInfoView.show(inView: view)
    }
    
    private func meetingLeaveBtnAction() {
        let isHostOrModerator = RCVMeetingDataSource.isHostOrModerator()
        let actionSheet = RCVMeetingAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let leaveAction = RCVMeetingAlertAction(title: "Leave meeting", style: .default) {
            [weak self] _ in
            self?.leaveMeeting()
        }
        
        let endAction = RCVMeetingAlertAction(title: "End meeting for everyone", style: .destructive, handler: {
            [weak self] _ in
            guard let self = self else {
                return
            }
            self.endMeeting()
        })
        
        let cancelAction = RCVMeetingAlertAction(title: "Cancel", style: .cancel, handler: { _ in })
        
        if isHostOrModerator {
            actionSheet.addAction(leaveAction)
            actionSheet.addAction(endAction)
            actionSheet.addAction(cancelAction)
            
            let viewController = RootController.shared.modalViewController()
            actionSheet.showAlertController(viewController, handler: nil)
        } else {
            self.leaveMeeting()
        }
    }
    
    private func sceenShareBtnAction() {
        startSharing()
    }
    
    private func participantBtnAction() {
        let participantVC = RCVParticipantListViewController()
        self.participantViewDelegate = participantVC
        
        presentLikePushVC(participantVC)
    }
    
    private func presentLikePushVC(_ viewcontroller: UIViewController) {
        let navVC = RCVGestureNavigationController(rootViewController: viewcontroller)
        
        navVC.modalPresentationStyle = RCVMeetingDataSource.modalPresentationStyle()
        
        if !RCVMeetingDataSource.isIPad() {
            let exitGestureRegconizer = ScreenEdgeTransitionGestureRecognizer(target: self, action: #selector(onPanGestureRecognizer(_:)))
            
            exitGestureRegconizer.edges = .left
            viewcontroller.view.addGestureRecognizer(exitGestureRegconizer)
            exitGestureRegconizer.require(toFail: navVC.interactivePopGestureRecognizer!)
        }
        
        present(navVC, animated: true) {}
    }
    
    @objc private func onPanGestureRecognizer(_ gesture: UIPanGestureRecognizer) {
        guard let gr = gesture as? TransitionGestureRecognizerProtocol else {
            return
        }
        
        switch gesture.state {
        case .began:
            transitionManager.begin()
            if let presentedViewController = presentedViewController {
                presentedViewController.dismiss(animated: true, completion: nil)
            }
        case .changed:
            transitionManager.update(gr.completion(isEnded: false))
        default:
            if gr.completion(isEnded: true) > 0.5 {
                transitionManager.finish()
            } else {
                transitionManager.cancel()
            }
        }
    }
}
