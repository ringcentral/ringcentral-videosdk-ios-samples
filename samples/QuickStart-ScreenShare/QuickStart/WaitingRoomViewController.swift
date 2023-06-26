//
//  WaitingRoomViewController.swift
//  RcvSwiftSample1v1meeting
//
//  Created by Yi Ke on 7/25/22.
//

import UIKit
import rcvsdk

class WaitingRoomViewController: UIViewController {
    
    @IBOutlet weak var waitingRoomLabel: UILabel!
    
    private var meetingId: String?
    private var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Leave", style: .done, target: self, action: #selector(onLeaveMeeting(sender:)))
        self.waitingRoomLabel.numberOfLines = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.waitingRoomLabel.text = self.message
    }
    
    @objc func onLeaveMeeting(sender: UIBarButtonItem) {
        guard let meetingController = RcvEngine.instance().getMeetingController(self.meetingId ?? "") else {
            return
        }

        meetingController.leaveMeeting()
    }
    
    @objc func onWaitingRoomAction(_ meetingId: String, message: String) {
        self.meetingId = meetingId
        self.message = message
        self.waitingRoomLabel?.text = message
    }
}
