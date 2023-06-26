//
//  RCVMeetingMainGalleryViewController.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

class RCVMeetingMainGalleryViewController: UIViewController {
    private(set) var pageIndex: Int = 0
    
    public var participants: [RcvIParticipant] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private var cells: [String] = ["cell1", "cell2", "cell3", "cell4", "cell5", "cell6", "cell7", "cell8", "cell9", "cell10", "cell11", "cell12", "cell13", "cell14", "cell15", "cell16"]
    
    lazy var flowLayout: RCVMeetingGalleryViewLayout = {
        var flowlayout = RCVMeetingGalleryViewLayout()
        return flowlayout
    }()
    
    lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: self.flowLayout)
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = false
        cv.backgroundColor = RCVColor.get(.neutralB05)
        cells.forEach { identifier in
            cv.register(RCVParticipantsListCell.self, forCellWithReuseIdentifier: identifier)
        }

        cv.accessibilityIdentifier = "RCVMeetingMainGalleryView"
        cv.backgroundColor = UIColor.clear
        cv.isScrollEnabled = false
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
    }
    
    private func addSubviews() {
        view.backgroundColor = UIColor.clear

        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.makeConstraintsToBindToSuperview()
    }
}

extension RCVMeetingMainGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return participants.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let participant = participants[indexPath.item]
        let cell: RCVParticipantsListCell
//        if participant.isMe() {
//
//        } else {
//            let identifier = cells[indexPath.item]
//            cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! RCVParticipantsListCell
//        }

        let identifier = cells[indexPath.item]
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! RCVParticipantsListCell
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}
