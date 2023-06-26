//
//  RCVMeetingLayoutView.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk
class RCVMeetingGalleryViewLayout: UICollectionViewLayout {
    
}

enum RCVMeetingLayoutType: Int {
    case Gallery

    func title() -> String {
        switch self {
        case .Gallery:
            return "Gallery"
        }
    }
}

protocol RCVLayoutChangeDelegate: AnyObject {
    func layoutDidChanged(from oldLayout: RCVMeetingLayoutType, to newLayout: RCVMeetingLayoutType)
    
    func onParticipantsListChange()
}

class RCVMeetingLayoutManager {
    weak var delegate: RCVLayoutChangeDelegate?
    private(set) var currentLayout: RCVMeetingLayoutType = .Gallery {
        didSet {
            delegate?.layoutDidChanged(from: oldValue, to: currentLayout)
        }
    }
    
    func updateLayout(layout: RCVMeetingLayoutType) {
        self.currentLayout = layout
    }
    
    func updateParticipantsList() {
        self.delegate?.onParticipantsListChange()
    }
}
