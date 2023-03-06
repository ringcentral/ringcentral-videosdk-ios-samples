//
//  ViewController.swift
//  RcvSwiftSample1v1meeting
//
//  Created by Yi Ke on 7/21/22.
//

import UIKit
import AVKit
import rcvsdk

class ViewController: UIViewController {

    @IBOutlet weak var meetingIdTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    private var meetingId: String?
    private var joined: Bool?
    private var engineEventHandler: RcvEngineEventHandler?
    private var waitingRoomViewController: WaitingRoomViewController?
    private var activeMeetingViewController: ActiveMeetingViewController?
    
    var window: UIWindow? {
        didSet {
            RootController.shared.window = window
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AVCaptureDevice.requestAccess(for: AVMediaType.audio) { response in }
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in }
        
        engineEventHandler = EngineEventHandler(delegate: self)
        RcvEngine.instance().register(engineEventHandler)
        
        let mainStoryboard = UIStoryboard(name:"Main", bundle: Bundle.main)
        
        self.activeMeetingViewController = mainStoryboard.instantiateViewController(withIdentifier:"Active Meeting") as? ActiveMeetingViewController

        self.waitingRoomViewController = mainStoryboard.instantiateViewController(withIdentifier: "Waiting Room") as? WaitingRoomViewController
    }
    
    @IBAction func onStartMeetingAction(_ sender: Any) {
        RcvEngine.instance().startInstantMeeting()
        showLoading()
    }
    
    @IBAction func onJoinMeetingAction(_ sender: Any) {
        let meetingId = meetingIdTextField.text ?? ""
        let userName = userNameTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        let opt = RcvMeetingOptions.create();
        opt?.setUserName(userName)
        opt?.setPassword(password)
        RcvEngine.instance().joinMeeting(meetingId, options: opt!)
        showLoading()
    }
    
    func showLoading() {
        let alert = UIAlertController(title: nil, message: "Connect...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    private func initRootViewController() {
        window = UIWindow(frame: UIScreen.main.bounds)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateInitialViewController()

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        OverlayWindowManager.shared.mainWindow = window
        OverlayWindowManager.shared.overlayWindow.rootViewController = self.activeMeetingViewController
    }
}

extension ViewController: RcvEngineEventHandler
{
    func onAuthorization(_ newTokenJsonStr: String) {
    }
    
    func onAuthorizationError(_ errorCode: Int64) {
    }
    
    func onMeetingBridge(_ info: RcvMeetingBridgeInfo?) {
    }
    
    func onAuthTokenRenew(_ errorCode: Int64, newTokenJsonStr: String) {
        if(RcvErrorCodeType.errOk == RcvEngine.getErrorType(errorCode)) {
            Toast.show(message: "The authorization token is renewed successfully.", duration: 3.0, controller: self)
        }
        else {
            Toast.show(message: "The authorization token renewal failed.", duration: 3.0, controller: self)
        }
    }
    
    func onMeetingJoin(_ meetingId: String, errorCode: Int64) {
        dismiss(animated: false, completion: nil)
        let type = RcvEngine.getErrorType(errorCode)
        if (type == RcvErrorCodeType.errOk && !meetingId.isEmpty && !(self.joined ?? false)) {
            initRootViewController()
            self.meetingId = meetingId
            self.activeMeetingViewController?.meetingId = meetingId
            self.joined = true
            self.activeMeetingViewController?.onMeetingJoin(meetingId, errorCode: errorCode)
            self.navigationController?.pushViewController(self.activeMeetingViewController!, animated: false)
        }
        else {
            switch (type) {
                case .errNeedPassword:
                    Toast.show(message: "The meeting password is required to join the meeting.", duration: 5.0, controller: self)
                    break;
                case .errInWaitingRoom:
                    self.waitingRoomViewController?.onWaitingRoomAction(meetingId, message: "You are in the waiting room, you will join the meeting once the meeting host admits you.")
                    if (isWaitingRoomViewControllerExist()) {
                        self.navigationController?.popToViewController(self.waitingRoomViewController!, animated: true)
                    } else {
                        self.navigationController?.pushViewController(self.waitingRoomViewController!, animated: true)
                    }
                    break;
                case .errWaitingHostJoinFirst:
                    self.waitingRoomViewController?.onWaitingRoomAction(meetingId, message: "You will join the meeting once the meeting host starts this meeting.")
                    if (isWaitingRoomViewControllerExist()) {
                        self.navigationController?.popToViewController(self.waitingRoomViewController!, animated: true)
                    } else {
                        self.navigationController?.pushViewController(self.waitingRoomViewController!, animated: true)
                    }
                    break;
                case .errDeniedFromWaitingRoom:
                    self.navigationController?.popViewController(animated: false)
                    Toast.show(message: "The meeting host denied you to join the meeting.", duration: 5.0, controller: self)
                    break;
                default:
                    Toast.show(message: "Failed to join the meeting.", duration: 5.0, controller: self)
                    break;
            }
        }
    }
    
    func onMeetingLeave(_ meetingId: String, errorCode: Int64, reason: RcvLeaveReason) {
        self.meetingId = ""
        self.joined = false
        self.navigationController?.popToRootViewController(animated: true)
        self.activeMeetingViewController?.onMeetingLeave(meetingId, errorCode: errorCode, reason: reason)
        
        switch (reason) {
            case .removeByHost:
                Toast.show(message: "The host has removed you from the meeting.", duration: 5.0, controller: self)
                break;
            case .endByHost:
                Toast.show(message: "The host ended the meeting.", duration: 5.0, controller: self)
                break;
            case .endByConnectionBroken:
                Toast.show(message: "The meeting ended due to the connection has broken.", duration: 5.0, controller: self)
                break;
            case .endForTimeLimit:
                Toast.show(message: "The meeting ended due to the time limit exceeded.", duration: 5.0, controller: self)
                break;
            case .deniedFromWaitingRoom:
                Toast.show(message: "The meeting host denied you to join the meeting.", duration: 5.0, controller: self)
            case .leaveBySelf:
                Toast.show(message: "You have left the meeting.", duration: 5.0, controller: self)
                break;
            default:
                Toast.show(message: "You have left the meeting.", duration: 5.0, controller: self)
                break;
        }
    }
    
    func onMeetingStateChanged(_ meetingId: String, state: RcvMeetingState) {
        switch (state) {
            case .inWaitingRoom:
                self.waitingRoomViewController?.onWaitingRoomAction(meetingId, message: "Host has moved you into the waiting room, you will join the meeting once the meeting host admits you.")
                if (isWaitingRoomViewControllerExist()) {
                    self.navigationController?.popToViewController(self.waitingRoomViewController!, animated: true)
                } else {
                    self.navigationController?.pushViewController(self.waitingRoomViewController!, animated: true)
                }
                break;
            case .inMeeting:
                self.activeMeetingViewController?.onMeetingJoin(meetingId, errorCode: 0)
                if (isActiveMeetingViewControllerExist()) {
                    self.navigationController?.popToViewController(self.activeMeetingViewController!, animated: true)
                } else {
                    self.navigationController?.pushViewController(self.activeMeetingViewController!, animated: true)
                }
                break;
            default:
                break;
        }
    }
    
    func onAuthTokenError(_ errorCode: Int64) {
    }
    
    func onMeetingSchedule(_ errorCode: Int64, settings: RcvScheduleMeetingSettings?) {
    }
    
    func onPersonalMeetingSettingsUpdate(_ errorCode: Int64, settings: RcvPersonalMeetingSettings?) {
    }
    
    func isActiveMeetingViewControllerExist() -> Bool {
        if let viewControllers = self.navigationController?.viewControllers {
            for controller in viewControllers {
                if controller is ActiveMeetingViewController {
                    return true
                }
            }
        }
        return false
    }
    
    func isWaitingRoomViewControllerExist() -> Bool {
        if let viewControllers = self.navigationController?.viewControllers {
            for controller in viewControllers {
                if controller is WaitingRoomViewController {
                    return true
                }
            }
        }
        return false
    }
}

