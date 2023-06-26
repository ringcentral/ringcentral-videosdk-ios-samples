//
//  RCVParticipantListViewController.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 2/13/23.
//

import UIKit
import rcvsdk

enum ParticipantListSectionType: Int {
    case invitation
    case waitingRoom
    case activeCall
    case notConnected
    case attendee

    func sectionTitle() -> String {
        switch self {
        case .activeCall:
            return "In meeting"
        case .notConnected:
            return "Not Connected"
        case .waitingRoom:
            return "In waiting room"
        default:
            return ""
        }
    }
}

protocol RCVParticipantListViewDelegate: AnyObject {
    func updateParticipantListViewSection()
}

class RCVParticipantListViewController : UIViewController {
    var participantActiveCellID = "ParticipantCellID"
    var participantNotconnectCellID = "ParticipantNotconnectCellID"
    var participantInviteCellID = "ParticipantInviteCellID"
    var participantHeaderID: String = "ParticipantHeaderID"
    var participantWaitingRoomHeaderID = "ParticipantWaitingRoomHeaderID"
    var participantWaitingRoomCellID = "ParticipantWaitingRoomCellID"
    
    public var inMeetingNum: Int = 0
    public var inWaitingRoomNum: Int = 0
    public var notConnectedNum: Int = 0
    
    private var showMoreButton: UIBarButtonItem?
    weak var filterHeaderView: ParticipantReactionsFilterHeader?
    
    private lazy var titleView: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = RCVColor.get(.headerText)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    var tableView: ParticipantTableView = {
        let tableView = ParticipantTableView(frame: .zero, style: .plain)
        tableView.backgroundColor = RCVColor.get(.neutralB05)
        tableView.keyboardDismissMode = .onDrag
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.separatorColor = .darkGray//RCVColor.get(.neutralL02)
        tableView.tableFooterView = UIView()
        tableView.accessibilityIdentifier = "participantTableView"
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    public weak var baseStackView: UIStackView? {
        didSet {
            //initBannerView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        setupSubView()
        addTitleView()
        updateTitleView()
        setupRightBarButtonItem()
        
        updateParticipantListViewSection()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        RCVMeetingDataSource.clearParticipantListViewSectionNum()
    }
    
    private func setupSubView() {
        setupTableView()
    }
    
    private func setupRightBarButtonItem() {
        let moreIcon = UIImage.fontAwesomeIcon(name: GFIName.GFIMoreAction.rawValue, iconColor: RCVColor.get(.headerIcon), fontSize: 17, backgroundColor: UIColor.clear)
        
        showMoreButton = UIBarButtonItem(image: moreIcon, style: .plain, target: self, action: #selector(RCVParticipantListViewController.showMoreButtonAction))
        showMoreButton?.accessibilityLabel = "More"
        navigationItem.rightBarButtonItem = showMoreButton

        if RCVMeetingDataSource.isHostOrModerator() {
            showMoreButton?.isEnabled = true
            showMoreButton?.tintColor = RCVColor.get(.headerIcon)
            showMoreButton?.accessibilityElementsHidden = false
            showMoreButton?.isAccessibilityElement = true
        }
    }
    
    @objc func showMoreButtonAction() {
        let muteAllAllowAction = RCVMeetingAlertAction(title: "Mute All - allow unmuting", style: .default) {
            _ in
            let audioController = RCVMeetingDataSource.getAudioController()
            audioController?.muteAllRemoteAudioStreams(true)
        }
        
        let muteAllBlockAction = RCVMeetingAlertAction(title: "Mute All - block unmuting", style: .default) {
            _ in
            let audioController = RCVMeetingDataSource.getAudioController()
            audioController?.muteAllRemoteAudioStreams(false)
        }
        
        let unmuteAll = RCVMeetingAlertAction(title: "Unmute all", style: .default) {
            _ in
            let audioController = RCVMeetingDataSource.getAudioController()
            audioController?.unmuteAllRemoteAudioStreams()
        }
        
        let disableVideoAllowAction = RCVMeetingAlertAction(title: "Disable Video - allow enabling", style: .default) {
            _ in
            let videoController = RCVMeetingDataSource.getVideoController()
            videoController?.muteAllRemoteVideoStreams(true)
        }
        
        let disableVideoBlockAction = RCVMeetingAlertAction(title: "Disable Video - block enabling", style: .default) {
            _ in
            let videoController = RCVMeetingDataSource.getVideoController()
            videoController?.muteAllRemoteVideoStreams(false)
        }
        
        let enableVideoAll = RCVMeetingAlertAction(title: "Enable video for all", style: .default) {
            _ in
            let videoController = RCVMeetingDataSource.getVideoController()
            videoController?.unmuteAllRemoteVideoStreams()
        }
        
        let cancelAction = RCVMeetingAlertAction(title: "Cancel", style: .default, handler: { _ in })
        
        RCVMeetingAlertManager.sharedInstance.showAlertOfTitle(title, text: nil, style: .alert, actions: [muteAllAllowAction, muteAllBlockAction, unmuteAll, disableVideoAllowAction, disableVideoBlockAction, enableVideoAll, cancelAction], viewController: self, additionObject: nil, completion: nil)
    }
    
    private func addTitleView() {
        navigationItem.titleView = titleView
        titleView.frame = CGRect(x: 0, y: 0, width: 220, height: 40)
        
        updateTitleView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapTitleView))
        titleView.addGestureRecognizer(tap)
    }
    
    private func updateTitleView() {
        let attrText = getParticipantsTitle()
        titleView.attributedText = attrText
        
        let meetingController = RCVMeetingDataSource.getMeetingController()
        let isLock = meetingController!.isMeetingLocked()
        titleView.accessibilityLabel = (isLock ? "Meeting locked" + "," : "") + attrText.string
        titleView.accessibilityValue = nil
    }
    
    private func getParticipantsTitle() -> NSAttributedString {
        let count = RCVMeetingDataSource.getParticioantCount()
        
        let meetingController = RCVMeetingDataSource.getMeetingController()
        let isLock = meetingController!.isMeetingLocked()
        
        let participantCountDesc: String = count > 1 ? "Participants" : "Participant"
        
        let participantCountTitle = "\(participantCountDesc) (\(count))"
        let createText = { (font: UIFont, lockFont: UIFont?) -> NSAttributedString in
            let text = NSMutableAttributedString(string: participantCountTitle, attributes: [NSAttributedString.Key.font: font])
            if let lock = lockFont {
                let lockIcon = NSAttributedString(string: " " + "\u{E9E1}", attributes: [NSAttributedString.Key.font: lock])
                text.append(lockIcon)
            }
            return text
        }
        
        if isLock {
            return createText(UIFont.boldSystemFont(ofSize: 17.0), UIFont(name: "GlipFont", size: 16.0))
        } else {
            return createText(UIFont.boldSystemFont(ofSize: 17.0), nil)
        }
    }
    
    @objc func didTapTitleView() {
        view.endEditing(true)
    }
    
    private func setupTableView() {
        tableView.register(ParticipantCell.self, forCellReuseIdentifier: participantActiveCellID)
        tableView.register(RCVParticipantsNotconnectCell.self, forCellReuseIdentifier: participantNotconnectCellID)
        tableView.register(ParticipantInviteCell.self, forCellReuseIdentifier: participantInviteCellID)
        tableView.register(RCVTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: participantHeaderID)
        tableView.register(ParticipantWaitingRoomAdmitAllHeader.self, forHeaderFooterViewReuseIdentifier: participantWaitingRoomHeaderID)
        tableView.register(RCVParticipantWaitingRoomCell.self, forCellReuseIdentifier: participantWaitingRoomCellID)
        
        tableView.delegate = self
        tableView.dataSource = self

        let stackview = UIStackView(arrangedSubviews: [tableView])
        stackview.backgroundColor = .clear
        stackview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackview)
        stackview.axis = .vertical
        stackview.spacing = 0
        stackview.distribution = .fill
        stackview.alignment = .fill
        stackview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        stackview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        baseStackView = stackview
        baseStackView?.backgroundColor = .clear
    }
    
    func processTapOnParticipant(indexPath: IndexPath, participantEntity: RcvIParticipant?, sectionType: ParticipantListSectionType) {
        guard !UIAccessibility.isVoiceOverRunning else {
            return
        }
        
        guard let participantEntity = participantEntity else {
            return
        }

        guard !participantEntity.isMe() else {
            return
        }
        if participantEntity.isPstn() && !participantEntity.hasNonPstnSession() {
            return
        }
        /// Condition: if section is " waiting room", should return
        if sectionType == ParticipantListSectionType.waitingRoom {
            return
        }
        
        let chatController = RCVMeetingDataSource.getChatController()
        guard chatController!.getCurrentChatPrivilege() == .everyone || participantEntity.isHost() || participantEntity.isModerator() else {
            let title = "Cannot chat"
            let content = "Chat disabled by the moderator."
            let okAction = RCVMeetingAlertAction(title: "OK", style: .default, handler: nil)
            RCVMeetingAlertManager.sharedInstance.showAlertOfTitle(title, text: content, style: .alert, actions: [okAction], viewController: RootController.shared.modalViewController(), additionObject: nil, completion: nil)
            return
        }
    }
    
    public func sectionType(_ section: Int) -> ParticipantListSectionType {
        switch section {
        case 0:
            return .invitation
        case 1:
            if inWaitingRoomNum > 0 {
                return .waitingRoom
            } else {
                return .activeCall
            }
        case 2:
            if inWaitingRoomNum > 0 {
                return .activeCall
            } else if notConnectedNum > 0 {
                return .notConnected
            }
            return .activeCall
        case 3:
            return .notConnected
        default:
            return .notConnected
        }
    }
}

extension RCVParticipantListViewController: RCVParticipantListViewDelegate {
    func updateParticipantListViewSection() {
        let activeParticipants = RCVMeetingDataSource.getActiveOneDevParticipantsList()
        let disconnectParticipants = RCVMeetingDataSource.getDisconnectParticipantList()
        let inWaitRoomParticipants = RCVMeetingDataSource.getInWaitRoomParticipantList()
        
        let currentInMeetingNum: Int = activeParticipants.count
        let currentInWaitRoomNum: Int = inWaitRoomParticipants.count
        let currentNotConnectNum: Int = disconnectParticipants.count
        
        // in meeting num
        if inMeetingNum == 0 && currentInMeetingNum > 0 {
            RCVMeetingDataSource.updateParticipantListViewSectionNum(isAdd: true)
        }
        inMeetingNum = currentInMeetingNum
        
        // in waitting room
        if inWaitingRoomNum == 0 && currentInWaitRoomNum > 0 {
            RCVMeetingDataSource.updateParticipantListViewSectionNum(isAdd: true)
        }
        else if inWaitingRoomNum > 0 && currentInWaitRoomNum == 0 {
            RCVMeetingDataSource.updateParticipantListViewSectionNum(isAdd: false)
        }
        inWaitingRoomNum = currentInWaitRoomNum
        
        // not connected
        if notConnectedNum == 0 && currentNotConnectNum > 0 {
            RCVMeetingDataSource.updateParticipantListViewSectionNum(isAdd: true)
        }
        else if notConnectedNum > 0 && currentNotConnectNum == 0 {
            RCVMeetingDataSource.updateParticipantListViewSectionNum(isAdd: false)
        }
        notConnectedNum = currentNotConnectNum
        
        self.updateTitleView()
        
        self.tableView.reloadData()
    }
}

extension RCVParticipantListViewController: RCVParticipantCellDelegate {
    func didTapParticipantMoreAction(cell: UITableViewCell) {
        let isHost = RCVMeetingDataSource.isHostOrModerator()
        
        if isHost == false {
            return
        }
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let section = indexPath.section
        if section > RCVMeetingDataSource.numberOfParticipantListViewSection() {
            return
        }
        
        var participant: RcvIParticipant?
        let sectionType = sectionType(section)
        if sectionType == .activeCall {
            let indexRow = indexPath.row
            let list = RCVMeetingDataSource.getActiveOneDevParticipantsList()
            participant = list[indexRow]
        }
        
        if participant == nil || participant!.isMe() {
            return
        }
        
        guard let userController = RCVMeetingDataSource.getMeetingUserController() else {
            return
        }
        
        let isMoerator = participant!.isModerator()
        
        var selectedUids = [NSNumber]()
        let uid = participant!.getModelId()
        selectedUids.append(uid as NSNumber)
        let moderatorAction = RCVMeetingAlertAction(title: isMoerator ? "Revoke Moderator" : "Make Moderator", style: .default) {
            _ in
            if isMoerator {
                userController.revokeModerators(selectedUids)
            } else {
                userController.assignModerators(selectedUids)
            }
        }
        
        let waitRoomAction = RCVMeetingAlertAction(title: "Move to waiting room", style: .default) {
            _ in
            userController.put(inWaitingRoom: uid)
        }
        
        let removeAction = RCVMeetingAlertAction(title: "Remove from meeting", style: .default) {
            _ in
            userController.removeUser(uid)
        }
        
        let cancelAction = RCVMeetingAlertAction(title: "Cancel", style: .default, handler: { _ in })
        
        let alertActions: [RCVMeetingAlertAction] = isMoerator ? [moderatorAction, removeAction, cancelAction] : [moderatorAction, waitRoomAction, removeAction, cancelAction]
        
        RCVMeetingAlertManager.sharedInstance.showAlertOfTitle(nil, text: nil, style: .alert, actions: alertActions, viewController: self, additionObject: nil, completion: nil)
    }
    
    func didTapAudioStatusAction(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let section = indexPath.section
        if section > RCVMeetingDataSource.numberOfParticipantListViewSection() {
            return
        }
        
        var participant: RcvIParticipant?
        let sectionType = sectionType(section)
        if sectionType == .activeCall {
            let indexRow = indexPath.row
            let list = RCVMeetingDataSource.getActiveOneDevParticipantsList()
            participant = list[indexRow]
        }
        
        if participant == nil {
            return
        }

        let isHost = RCVMeetingDataSource.isHostOrModerator()
        let isMute = participant!.audioLocalMute()
        let audioController = RCVMeetingDataSource.getAudioController()
        if participant!.isMe() {
            if isMute {
                if participant!.isAllowUmuteAudio() {
                    audioController?.unmuteLocalAudioStream()
                }
            } else {
                audioController?.muteLocalAudioStream()
            }
        } else if isHost {
            if isMute {
                audioController?.unmuteRemoteAudioStream(participant!.getModelId())
            } else {
                audioController?.muteRemoteAudioStream(participant!.getModelId())
            }
        }
    }
    
    func didTapVideoStatusAction(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let section = indexPath.section
        if section > RCVMeetingDataSource.numberOfParticipantListViewSection() {
            return
        }
        
        var participant: RcvIParticipant?
        let sectionType = sectionType(section)
        if sectionType == .activeCall {
            let indexRow = indexPath.row
            let list = RCVMeetingDataSource.getActiveOneDevParticipantsList()
            participant = list[indexRow]
        }
        
        if participant == nil {
            return
        }

        let isHost = RCVMeetingDataSource.isHostOrModerator()
        let isMute = participant!.audioLocalMute()
        let videoController = RCVMeetingDataSource.getVideoController()
        if participant!.isMe() {
            if isMute {
                if participant!.isAllowUmuteVideo() {
                    videoController?.unmuteLocalVideoStream()
                }
            } else {
                videoController?.muteLocalVideoStream()
            }
        } else if isHost {
            if isMute {
                videoController?.unmuteRemoteVideoStream(participant!.getModelId())
            } else {
                videoController?.muteRemoteVideoStream(participant!.getModelId())
            }
        }
    }
    
    func didTapInWaitRoomMoreAction(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let section = indexPath.section
        if section > RCVMeetingDataSource.numberOfParticipantListViewSection() {
            return
        }
        
        var participant: RcvIParticipant?
        let sectionType = sectionType(section)
        if sectionType == .waitingRoom {
            let indexRow = indexPath.row
            let inWaitRoomList = RCVMeetingDataSource.getInWaitRoomParticipantList()
            participant = inWaitRoomList[indexRow]
        }
        
        if participant == nil {
            return
        }
        
        let admitAction = RCVMeetingAlertAction(title: "Admit", style: .default) {
                _ in
            let uid = participant?.getModelId()
            let usercontroller = RCVMeetingDataSource.getMeetingUserController()
            usercontroller?.admitUser(uid!)
            }
        
        let denyAction = RCVMeetingAlertAction(title: "Deny", style: .default) {
                _ in
            let uid = participant?.getModelId()
            let usercontroller = RCVMeetingDataSource.getMeetingUserController()
            usercontroller?.denyUser(uid!)
            }
        
        let cancelAction = RCVMeetingAlertAction(title: "Cancel", style: .default, handler: { _ in })
               
        RCVMeetingAlertManager.sharedInstance.showAlertOfTitle(nil, text: nil, style: .alert, actions: [admitAction, denyAction, cancelAction], viewController: self, additionObject: nil, completion: nil)
    }
    
}

class ParticipantTableView: UITableView {
    var pinToTop: Bool = false
    override var contentOffset: CGPoint {
        get {
            return super.contentOffset
        }
        set {
            if pinToTop {
                super.contentOffset = .zero
            } else {
                super.contentOffset = newValue
            }
        }
    }
}
