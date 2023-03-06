//
//  RCVParticipantListViewController+UITableViewDelegate.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 2/13/23.
//

import UIKit
import rcvsdk

extension RCVParticipantListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.section == ParticipantListSectionType.invitation.rawValue {
            self.view.endEditing(true)
            let meetingController = RCVMeetingDataSource.getMeetingController()
            if meetingController!.isMeetingLocked() {
                let okAction = RCVMeetingAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
                let title = "Cannot Invite Participants."
                let text = "The meeting has been locked by the moderator."

                _ = RCVMeetingAlertManager.sharedInstance.showAlertOfTitle(title,
                                                                     text: text,
                                                                     style: UIAlertController.Style.alert,
                                                                     actions: [okAction],
                                                                     viewController: RootController.shared.modalViewController(),
                                                                     additionObject: nil, completion: nil)
            } else {
                if let nav = self.navigationController {
                    showInviteButtonAction(controller: nav)
                }
            }
        } else {
            let section = indexPath.section
            if section > RCVMeetingDataSource.numberOfParticipantListViewSection() {
                return
            }
            
            let sectionType = self.sectionType(section)
            if sectionType == .invitation {
                return
            }
            else if sectionType == .waitingRoom {
                
            }
            else if sectionType == .notConnected {
                
            } else {
                let indexRow = indexPath.row
                let participantList = RCVMeetingDataSource.getActiveOneDevParticipantsList()
                let particioant = participantList[indexRow]
                
                self.processTapOnParticipant(indexPath: indexPath, participantEntity: particioant, sectionType: sectionType)
            }
        }
    }
    
    private func showInviteButtonAction(controller: UIViewController) {
        let copyLinkAction = RCVMeetingAlertAction(title: "Copy meeting link", style: .default) {
                _ in
                let meetingControler = RCVMeetingDataSource.getMeetingController()
                let meetingUrl = meetingControler?.getMeetingInfo()?.meetingLink()
                UIPasteboard.general.string = meetingUrl
                Toast.show(message: "Meeting URL copied", duration: 3.0, controller: controller)
            }
        
        let cancelAction = RCVMeetingAlertAction(title: "Cancel", style: .default, handler: { _ in })
               
               RCVMeetingAlertManager.sharedInstance.showAlertOfTitle(nil, text: nil, style: .alert, actions: [copyLinkAction, cancelAction], viewController: self, additionObject: nil, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        let num = RCVMeetingDataSource.numberOfParticipantListViewSection()
        
        return num
    }
    
    private func numberOfRows(inSection: Int) -> Int {
        var rowsNumber: Int = 0
        switch inSection {
        case 0:
            rowsNumber = 1
            break
        case 1:
            if self.inWaitingRoomNum > 0 {
                rowsNumber = self.inWaitingRoomNum
            } else {
                rowsNumber = self.inMeetingNum
            }
        case 2:
            if self.inWaitingRoomNum > 0 {
                rowsNumber = self.inMeetingNum
            } else {
                rowsNumber = self.notConnectedNum
            }
        case 3:
            rowsNumber = self.notConnectedNum
        default:
            rowsNumber = 0
        }
        
        return rowsNumber
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRows(inSection: section)
    }

    private func deviceNumberInSection(inSection: Int) -> Int {
        let rows = numberOfRows(inSection: inSection)
        
        let participantList = RCVMeetingDataSource.getActiveOneDevParticipantsList()
        let participantCpount = participantList.count
        let rowNum = rows < participantCpount ? rows : participantCpount
        
        var deviceVount: Int = 0
        for i in 0..<rowNum {
            let particioant = participantList[i]
            deviceVount += Int(particioant.getActiveDeviceCount())
        }
        
        return deviceVount
    }
    
    private func displayMeetingTitle(with peopleCount: Int, deviceCount: Int) -> String {
        var text: String = ""
        switch (peopleCount, deviceCount) {
        case _ where peopleCount == deviceCount:
            return "\(peopleCount)"
        case (1, _):
            text = String(1) + " person, " + String(deviceCount) + " devices"
            return text
        default:
            text = String(peopleCount) + " person, " + String(deviceCount) + " devices"
            return text
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > RCVMeetingDataSource.numberOfParticipantListViewSection() {
            return nil
        }
        
        let sectionType = self.sectionType(section)
        if sectionType == .invitation {
            return nil
        }
        
        let rows = numberOfRows(inSection: section)
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.participantHeaderID) as! RCVTableViewSectionHeader
        switch sectionType {
        case .waitingRoom:
            let text = " (" + String(rows) + ")"
            sectionHeader.sectionTextLabel?.text = sectionType.sectionTitle() + text
            return sectionHeader
        case .notConnected:
            sectionHeader.sectionTextLabel?.text = sectionType.sectionTitle()
            return sectionHeader
        default:
                // multi devices with participant count text
            let deviceCount = deviceNumberInSection(inSection: section)
            let participantsCountText = "(\(self.displayMeetingTitle(with: rows, deviceCount: deviceCount)))"

            var sectionTitle = sectionType.sectionTitle()
            self.filterHeaderView = nil
            sectionHeader.sectionTextLabel?.text = sectionTitle + " " + participantsCountText
            return sectionHeader
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let sectionNum = RCVMeetingDataSource.numberOfParticipantListViewSection()
        if section >  sectionNum{
            return UITableViewCell()
        }
        
        let sectionType = self.sectionType(section)
        if sectionType == .invitation {
            let cell = tableView.dequeueReusableCell(withIdentifier: self.participantInviteCellID, for: indexPath) as! ParticipantInviteCell
            return cell
        }
        else if sectionType == .waitingRoom {
            let cell = tableView.dequeueReusableCell(withIdentifier: participantWaitingRoomCellID, for: indexPath) as! RCVParticipantWaitingRoomCell
            let indexRow = indexPath.row
            let inWaitRoomList = RCVMeetingDataSource.getInWaitRoomParticipantList()
            let particioant = inWaitRoomList[indexRow]
            cell.actionDelegate = self
            
            configure(with: cell, participant: particioant)
            return cell
        }
        else if sectionType == .notConnected {
            let cell = tableView.dequeueReusableCell(withIdentifier: participantNotconnectCellID, for: indexPath) as! RCVParticipantsNotconnectCell
            let indexRow = indexPath.row
            let disconnectList = RCVMeetingDataSource.getDisconnectParticipantList()
            let particioant = disconnectList[indexRow]
            
            configure(with: cell, participant: particioant)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: participantActiveCellID, for: indexPath) as! ParticipantCell
            cell.actionDelegate = self
            let indexRow = indexPath.row
            let participantList = RCVMeetingDataSource.getActiveOneDevParticipantsList()
            let particioant = participantList[indexRow]
            
            configure(with: cell, participant: particioant)
            return cell
        }
        
        return UITableViewCell()
    }
    
    private func configure(with cell: ParticipantCell, participant: RcvIParticipant) {
        cell.configCell(participant: participant)
    }
    
    private func configure(with cell: RCVParticipantsNotconnectCell, participant: RcvIParticipant) {
        cell.configCell(participant: participant)
    }
    
    private func configure(with cell: RCVParticipantWaitingRoomCell, participant: RcvIParticipant) {
        cell.configCell(participant: participant)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionType = self.sectionType(section)
        if sectionType == .invitation{
            return 0
        }

        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        if section == ParticipantListSectionType.invitation.rawValue {
            return 0
        }
        return 32
    }
}
