//
//  SampleHandler.swift
//  QuickStartBroadcast
//
//  Created by Conch Feng on 2023/6/26.
//

import ReplayKit
import RcvReplayKitExtension

class SampleHandler: RPBroadcastSampleHandler {

    private var appGroupName: String {
        // Note: replace with Your App Group Identifier.
        return "group.com.ringcentral.rcv.sample"
    }
    
    func createRcvService() -> RcvScreenShareService {
        let result = RcvScreenShareService()
        result.appGroup = appGroupName
        result.delegate = self
        return result
    }
    
    var rcvService: RcvScreenShareService?
    
    override init() {
        super.init()
    }
    
    deinit {
        rcvService?.delegate = nil
        rcvService = nil
    }
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        let rcvSvc = createRcvService()
        if rcvSvc.broadcastStarted(withSetupInfo: setupInfo) {
            rcvService = rcvSvc
        }
        print("broadcastStarted:\(setupInfo ?? [:])")
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
        if let rcvService = rcvService {
            rcvService.broadcastPaused()
        }
        print("broadcastPaused")
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
        if let rcvService = rcvService {
            rcvService.broadcastResumed()
        }
        print("broadcastResumed")
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
        if let rcvService = rcvService {
            rcvService.broadcastFinished()
        }
        print("broadcastFinished")
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        if let rcvService = rcvService {
            rcvService.processSampleBuffer(sampleBuffer, with: sampleBufferType)
        }
    }
}

extension SampleHandler: RcvScreenShareServiceDelegate {
    private func rcvScreenShareServiceErrorToString(errorCode: Int) -> String {
        switch errorCode {
        case RCVRPRecordingErrorCommunication, RCVRPRecordingErrorSharingHasBeenFailed:
            return "The screen sharing has been stopped due to internal error."
        case RCVRPRecordingErrorMeetingOrSharingEnded:
            return "The screen sharing or the meeting has been ended."
        case RCVRPRecordingErrorSharingHasBeenCancelled, RCVRPRecordingErrorLostConnectionToHostApp:
            return "Screen sharing has ended."
        case RCVRPRecordingErrorSharingHasBeenInterrupted:
            return "Another participant has started screen sharing."
        case RCVRPRecordingErrorMeetingHasBeenEnded:
            return "This meeting has ended."
        default:
            return ""
        }
    }
    
    func rcvScreenShareServiceFinishBroadcastWithError(_ error: Error) {
        let nsError = error as NSError
        let errorString = rcvScreenShareServiceErrorToString(errorCode: nsError.code)
        var userInfo = nsError.userInfo
        print("finishRCVBroadcastWithError:\(nsError.code)")
        userInfo[NSLocalizedDescriptionKey] = errorString
        userInfo[NSLocalizedFailureReasonErrorKey] = errorString
        finishBroadcastWithError(NSError(domain: nsError.domain, code: nsError.code, userInfo: userInfo))
    }
}
