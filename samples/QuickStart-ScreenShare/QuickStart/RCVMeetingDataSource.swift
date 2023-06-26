//
//  RCVMeetingDataSource.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

public enum SpeakerPhoneType {
    case phone
    case speaker
    case bluetooth
}

public class RCVMeetingDataSource {
    private static var meetingId: String?
    
    private static var currentSpeakerPhoneType: SpeakerPhoneType = .phone
    private static var currentAudioRouteType: RcvAudioRouteType = .audioRouteDefault
    private static var currentVideoMute: Bool = true
    
    public static var activeParticipants: [RcvIParticipant] = []
    public static var activeOneDeviceParticipants: [RcvIParticipant] = []
    public static var disconnectParticipants: [RcvIParticipant] = []
    public static var inWaitRoomParticipants: [RcvIParticipant] = []
    
    public static var participantListViewSectionNum: Int = 1
    
    public static func setMeetingId(id: String) {
        meetingId = id
    }
    
    public static func clearData() {
        meetingId = nil
        participantListViewSectionNum = 1
        currentSpeakerPhoneType = .phone
        currentAudioRouteType = .audioRouteDefault
        currentVideoMute = true
        activeOneDeviceParticipants = []
        disconnectParticipants = []
        inWaitRoomParticipants = []
        activeParticipants = []
    }
    
    public static func getMeetingController() -> RcvMeetingController? {
        let meetingController = RcvEngine.instance().getMeetingController(self.meetingId ?? "")
        
        return meetingController
    }
    
    public static func getMeetingUserController() -> RcvMeetingUserController? {
        guard let meetingController = getMeetingController() else {
            return nil
        }
        
        return meetingController.getMeetingUserController()
    }
    
    public static func getAudioController() -> RcvAudioController? {
        guard let meetingController = getMeetingController() else {
            return nil
        }
        
        return meetingController.getAudioController()
    }
    
    public static func getVideoController() -> RcvVideoController? {
        guard let meetingController = getMeetingController() else {
            return nil
        }
        
        return meetingController.getVideoController()
    }
    
    public static func getSharingController()-> RcvSharingController? {
        guard let meetingController = getMeetingController() else {
            return nil
        }
        
        return meetingController.getSharingController()
    }
    
    public static func getChatController()-> RcvMeetingChatController? {
        guard let meetingController = getMeetingController() else {
            return nil
        }
        
        return meetingController.getMeetingChatController()
    }
    
    public static func clearParticipants() {
        self.activeParticipants.removeAll()
        self.activeOneDeviceParticipants.removeAll()
        self.disconnectParticipants.removeAll()
        self.inWaitRoomParticipants.removeAll()
    }
    
    public static func updateParticipantInList(participant: RcvIParticipant) {
        var index:Int = 0
        for elem in self.activeOneDeviceParticipants {
            if elem.getModelId() == participant.getModelId(){
                self.activeOneDeviceParticipants[index] = participant
                break
            }
            
            index += 1
        }
        
        index = 0
        for elem in self.activeParticipants {
            if elem.getModelId() == participant.getModelId(){
                self.activeParticipants[index] = participant
                break
            }
            
            index += 1
        }
    }
    
    public static func insertParticipantToActiveList(participant: RcvIParticipant) {
        let arryCount =  self.activeParticipants.count
        if arryCount == 0 {
            let userController = getMeetingUserController()
            let me = userController?.getMyself()
            self.activeParticipants.append(me!)
        }
        
        if participant.isMe() {
            return
        }
        
        var index: Int = 0
        for elem in self.activeParticipants {
            if elem.isMe() == false {
                if elem.displayName() > participant.displayName() {
                    self.activeParticipants.insert(participant, at: index)
                    return
                }
            }
            
            index += 1
        }
        
        self.activeParticipants.append(participant)
    }
    
    public static func removeParticipantFromActiveList(participant: RcvIParticipant) {
        self.activeParticipants.removeAll(where: {$0.getModelId() == participant.getModelId()})
    }
    
    public static func insertParticipantToList(participant: RcvIParticipant) {
        let arryCount =  self.activeOneDeviceParticipants.count
        if arryCount == 0 {
            let userController = getMeetingUserController()
            let me = userController?.getMyself()
            self.activeOneDeviceParticipants.append(me!)
        }
        
        if participant.isMe() {
            return
        }
        
        var index: Int = 0
        for elem in self.activeOneDeviceParticipants {
            if elem.isMe() == false {
                if elem.displayName() > participant.displayName() {
                    self.activeOneDeviceParticipants.insert(participant, at: index)
                    return
                }
            }
            
            index += 1
        }
        
        self.activeOneDeviceParticipants.append(participant)
    }
    
    public static func removeParticipantFromList(participant: RcvIParticipant) {
        self.activeOneDeviceParticipants.removeAll(where: {$0.getPid() == participant.getPid()})
    }
    
    public static func insertParticipantToDisconnectList(participant: RcvIParticipant) {
        var index: Int = 0
        for elem in self.disconnectParticipants {
            if elem.isMe() == false {
                if elem.displayName() > participant.displayName() {
                    self.disconnectParticipants.insert(participant, at: index)
                    return
                }
            }
            
            index += 1
        }
        
        self.disconnectParticipants.append(participant)
    }
    
    public static func removeParticipantFromDisconnectList(participant: RcvIParticipant) {
        self.disconnectParticipants.removeAll(where: {$0.getPid() == participant.getPid()})
    }
    
    public static func insertParticipantToInWaitRoomList(participant: RcvIParticipant) {
        var index: Int = 0
        for elem in self.inWaitRoomParticipants {
            if elem.isMe() == false {
                if elem.displayName() > participant.displayName() {
                    self.inWaitRoomParticipants.insert(participant, at: index)
                    return
                }
            }
            
            index += 1
        }
        
        self.inWaitRoomParticipants.append(participant)
    }
    
    public static func removeParticipantFromInWaitRoomList(participant: RcvIParticipant) {
        self.inWaitRoomParticipants.removeAll(where: {$0.getPid() == participant.getPid()})
    }
    
    public static func getActiveParticipantsList() -> [RcvIParticipant] {
        return self.activeParticipants
    }
    
    public static func getActiveOneDevParticipantsList() -> [RcvIParticipant] {
        return self.activeOneDeviceParticipants
    }
    
    public static func getDisconnectParticipantList() -> [RcvIParticipant] {
        return self.disconnectParticipants
    }
    
    public static func getInWaitRoomParticipantList() -> [RcvIParticipant] {
        return self.inWaitRoomParticipants
    }
    
    public static func getParticioantCount()-> Int {
        return self.activeOneDeviceParticipants.count + self.disconnectParticipants.count + self.inWaitRoomParticipants.count
    }
    
    public static func getParticipants(from: Int32, end: Int32) -> [RcvIParticipant]{
        var participantsTmp: [RcvIParticipant] = []
        
        for i in from..<end {
            participantsTmp.append(self.activeOneDeviceParticipants[Int(i)])
        }
        
        return participantsTmp
    }
    
    public static func updateSpeakerPhoneType(_ audioRouteType: RcvAudioRouteType) {
        self.currentAudioRouteType = audioRouteType
        
        if currentAudioRouteType == .audioRouteSpeakerphone {
            currentSpeakerPhoneType = .speaker
        } else if currentAudioRouteType == .audioRouteEarpiece {
            currentSpeakerPhoneType = .phone
        } else if currentAudioRouteType == .audioRouteHeadsetbluetooth {
            currentSpeakerPhoneType = .bluetooth
        }
    }
    
    public static func getCurrentSpeakerPhoneType() -> SpeakerPhoneType {
        if currentAudioRouteType == .audioRouteDefault {
            let audioController = getAudioController()
            
            let isSpeaker = audioController?.isSpeakerphoneEnabled()
            
            currentAudioRouteType = isSpeaker! ? .audioRouteSpeakerphone : .audioRouteEarpiece
            
            currentSpeakerPhoneType = isSpeaker! ? .speaker : .phone
        }
        
        return self.currentSpeakerPhoneType
    }
    
    public static func updateVideoMuteStatus(_ muted: Bool) {
        self.currentVideoMute = muted
    }
    
    public static func getCurrentVideoMute() -> Bool{
        return self.currentVideoMute
    }
    
    public static func isHostOrModerator() -> Bool {
        let userController = getMeetingUserController()
        let me = userController?.getMyself()
        
        return me!.isHost() || me!.isModerator()
    }
    
    public static func isSharingCamera() -> Bool {
        let sharingController = getSharingController()
        
        /*is camera sharing to do*/
        return sharingController!.isLocalSharing()
    }
    
    public static func isIPhoneLandscapeOrRegularWidth(traitCollection: UITraitCollection) -> Bool {
        if isIPhone() {
            let orientation = UIApplication.shared.statusBarOrientation
            return orientation.isLandscape
        } else {
            return traitCollection.horizontalSizeClass == .regular
        }
    }
    
    public static func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    public static func isIPhoneModel() -> Bool {
        return (UIDevice.current.model == "iPhone") || (UIDevice.current.model == "iPhone Simulator")
    }
    
    public static func isIPhone() -> Bool {
        return !isIPad() && isIPhoneModel()
    }
    
    public static func modalPresentationStyle() -> UIModalPresentationStyle {
        if isIPad() {
            return .formSheet
        } else {
            return .fullScreen
        }
    }
    
    public static func numberOfParticipantListViewSection() -> Int {
        return self.participantListViewSectionNum
    }
    
    public static func updateParticipantListViewSectionNum(isAdd: Bool) {
        if isAdd == true {
            //self.participantListViewSectionNum += 1
            var num = self.participantListViewSectionNum
            num += 1
            self.participantListViewSectionNum = num
        } else {
            self.participantListViewSectionNum -= 1
        }
    }
    
    public static func clearParticipantListViewSectionNum() {
        self.participantListViewSectionNum = 1
    }
}

struct StatusIcon {
    let image: UIImage?
    let isEnabled: Bool

    static let audioOn = RCVColor.image(named: "mic_on")
    static let audioOnDisabled = RCVColor.image(named: "mic_on_disabled")
    static let audioOff = RCVColor.image(named: "mic_off")
    static let audioOffDisabled = RCVColor.image(named: "mic_off_disabled")

    static let dialInOn = RCVColor.image(named: "phone_on")
    static let dialInOnDisabled = RCVColor.image(named: "phone_on_disabled")
    static let dialInOff = RCVColor.image(named: "phone_off")
    static let dialInOffDisabled = RCVColor.image(named: "phone_off_disabled")

    static let videoOn = RCVColor.image(named: "video_on")
    static let videoOnDisabled = RCVColor.image(named: "video_on_disabled")
    static let videoOff = RCVColor.image(named: "video_off")
    static let videoOffDisabled = RCVColor.image(named: "video_off_disabled")

    static let audioOnHighlight = RCVColor.image(named: "mic_on")?.imageApplyColor(RCVColor.get(.successF02))
    static let dialInOnHighlight = RCVColor.image(named: "phone_on")?.imageApplyColor(RCVColor.get(.successF02))
}
