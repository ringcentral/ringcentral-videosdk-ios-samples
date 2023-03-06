//
//  RCVToolBarDataSource.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

enum MuteState {
    case joinAudio
    case mute
    case unMute
    case pstnMute
    case pstnUnmute
    case speaking(_ volume: CGFloat)
    case pstnSpeaking

    func iconName() -> String {
        switch self {
        case .joinAudio:
            return "iconsJoinaudio"
        case .mute:
            return "iconsMicMute"
        case .unMute, .speaking:
            return "iconsMic"
        case .pstnMute:
            return "iconsPstnMute"
        case .pstnUnmute, .pstnSpeaking:
            return "iconsPstnUnMute"
        }
    }

    func title() -> String {
        switch self {
        case .joinAudio:
            return "Join audio"
        case .mute:
            return "Unmute"
        case .unMute, .speaking:
            return "Mute"
        case .pstnMute:
            return "Unmute"
        case .pstnUnmute, .pstnSpeaking:
            return "Mute"
        }
    }

    func accessibilityLabel() -> String {
        switch self {
        case .joinAudio:
            return "Join audio"
        case .mute:
            return "Unmute"
        case .unMute, .speaking:
            return "Mute"
        case .pstnMute:
            return "Phone Unmute"
        case .pstnUnmute, .pstnSpeaking:
            return "Phone Mute"
        }
    }
}

enum VideoState {
    case start
    case stop

    func iconName() -> String {
        switch self {
        case .start:
            return "startVideo"
        case .stop:
            return "stopVideo"
        }
    }

    func title() -> String {
        switch self {
        case .start:
            return "Stop video"
        case .stop:
            return "Start video"
        }
    }

    func accessibilityLabel() -> String {
        switch self {
        case .start:
            return "Stop video"
        case .stop:
            return "Start video"
        }
    }
}

enum AudioChannel {
    case speaker
    case iPhone
    case bluetooth
    case earphones

    func iconName(_ disable: Bool) -> String {
        if disable {
            return "icNoSpeaker"
        }
        switch self {
        case .speaker:
            return "icSpeaker"
        case .iPhone:
            return "icSpeakerPhone"
        case .bluetooth:
            return "bluetoothSpeaker"
        case .earphones:
            return "iconsAudioEarphones"
        }
    }

    func title() -> String {
        switch self {
        case .speaker:
            return "Speaker"
        case .iPhone:
            return "iPhone"
        case .bluetooth:
            return "Bluetooth"
        case .earphones:
            return "Earphones"
        }
    }

    func accessibilityLabel() -> String {
        switch self {
        case .speaker:
            return "Speaker"
        case .iPhone:
            return "iPhone Speaker"
        case .bluetooth:
            return "Bluetooth"
        case .earphones:
            return "Earphones"
        }
    }
}

enum RCVToolBarItemType {
    case mute(_ state: MuteState)
    case video(_ state: VideoState)
    case audioChannel(_ state: AudioChannel)
    case chat(_ isLocked: Bool)
    case leave(hasEndPermission: Bool)
    case audio(_ isConnected: Bool)
    case participant(waitingNumber: Int?)
    case meetingInfo
    case networkState
}

extension RCVToolBarItemType: Equatable {
    static func == (lhs: RCVToolBarItemType, rhs: RCVToolBarItemType) -> Bool {
        switch (lhs, rhs) {
        case (.mute(_), .mute(_)):
            return true
        case (.video(_), .video(_)):
            return true
        case (.participant(_), .participant(_)):
            return true
        case (.chat(_), .chat(_)):
            return true
        case (.audioChannel(_), .audioChannel(_)):
            return true
        case (.leave, .leave):
            return true
        case (.audio(_), .audio(_)):
            return true
        default:
            return false
        }
    }
}

enum RCVMeetingItemState {
    case normal
    case selected
    case disable
    case locked
}

class RCVToolBarItem {
    var itemType: RCVToolBarItemType
    var state: RCVMeetingItemState
    
    init(itemType: RCVToolBarItemType, state: RCVMeetingItemState = .normal) {
        self.itemType = itemType
        self.state = state
    }
    
    enum Icon {
        case image(name: String)
    }
    
    func modelTuple() -> (iconName: Icon,
                          title: String,
                          accessibilityLabel: String,
                          accessibilityIdentifier: String,
                          accessibilityValue: String?) {
        switch itemType {
        case let .mute(state):
            return (iconName: .image(name: state.iconName()), title: state.title(), accessibilityLabel: state.accessibilityLabel(), accessibilityIdentifier: "bottomBar-audio", accessibilityValue: self.state == .locked ? "Locked": nil)
        case let .video(state):
            return (iconName: .image(name: state.iconName()), title: state.title(), accessibilityLabel: state.accessibilityLabel(), accessibilityIdentifier: "bottomBar-video", accessibilityValue: self.state == .locked ? "Locked" : nil)
        case let .chat(isLocked):
            return (iconName: .image(name: isLocked ? "iconsChatLock" : "iconsChat"), title: "Chat", accessibilityLabel: "Chat", accessibilityIdentifier: "bottomBar-chat", accessibilityValue: nil)
        case .participant:
            return (iconName: .image(name: "iconsParticipants"), title: "Participants", accessibilityLabel: "participants", accessibilityIdentifier: "bottomBar-participant", accessibilityValue: nil)
        case let .audioChannel(state):
            let isDisable = self.state == .disable
            return (iconName: .image(name: state.iconName(isDisable)), title: state.title(), accessibilityLabel: state.accessibilityLabel(), accessibilityIdentifier: "SpeakerButton", accessibilityValue: nil)
        case let .leave(hasEndPermission):
            let end = hasEndPermission ? "End" : "Leave"
            return (iconName: .image(name: "iconsHandup"), title: end, accessibilityLabel: "leave meeting", accessibilityIdentifier: "EndButton", accessibilityValue: nil)
        case let .audio(isConnected):
            return (iconName: .image(name: isConnected ? "rcv_disconnect_audio" : "rcv_connect_audio"), title: isConnected ? "Disconnect Audio" : "Connect Audio", accessibilityLabel: isConnected ? "Disconnect Audio" : "Connect Audio", accessibilityIdentifier: "ConnectAudioButton", accessibilityValue: nil)
        case .meetingInfo:
            return (iconName: .image(name: "icMeetingInfo"), title: "Information", accessibilityLabel: "meeting info", accessibilityIdentifier: "MeetingInfoButton", accessibilityValue: nil)
        case .networkState:
            return (iconName: .image(name: "img_self_good"), title: "Network", accessibilityLabel: "network state", accessibilityIdentifier: "NetWorkStateButton", accessibilityValue: nil)
        }
    }
}

class RCVToolBarDataSource{
    var speakerViewModel: RCVToolBarItem = {
        let speakerViewModel = RCVToolBarItem(itemType: .audioChannel(.iPhone),
                                               state: .disable)
        return speakerViewModel
    }()
    
    var chatViewModel: RCVToolBarItem = {
        let chat = RCVToolBarItem(itemType: .chat(false))
        return chat
    }()

    var leaveViewModel: RCVToolBarItem = {
        let leave = RCVToolBarItem(itemType: .leave(hasEndPermission: false))
        return leave
    }()
    
    var meetingInfoViewModel: RCVToolBarItem = {
        let meetingInfo = RCVToolBarItem(itemType: .meetingInfo)
        return meetingInfo
    }()
    
    var networkStateViewModel: RCVToolBarItem = {
        let networkState = RCVToolBarItem(itemType: .networkState)
        return networkState
    }()

    var audioViewModel: RCVToolBarItem = {
        let audio = RCVToolBarItem(itemType: .mute(.joinAudio))
        return audio
    }()

    var videoViewModel: RCVToolBarItem = {
        let video = RCVToolBarItem(itemType: .video(.start))
        return video
    }()

    var participantViewModel: RCVToolBarItem = {
        let participants = RCVToolBarItem(itemType: .participant(waitingNumber: nil))
        return participants
    }()
}
