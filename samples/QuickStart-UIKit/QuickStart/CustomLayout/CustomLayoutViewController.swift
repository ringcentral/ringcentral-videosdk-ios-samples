//
//  CustomLayoutViewController.swift
//  RCV-UIKit-Example
//
//  Created by Simon Xiang on 2023/6/26.
//

import UIKit
import Combine
import rcvsdk

class CustomLayoutViewController: UIViewController, UIScrollViewDelegate {
    private var currentPageIndex: Int = 0 {
        didSet {
            self.pageChanged()
        }
    }
    private var meetingID: String?
    private var cancelable = Set<AnyCancellable>()
    static var customLayoutModel: CustomLayoutModel?
    private var perPageCount: Int = 2
    
    private var pageControlBottomConstraint: NSLayoutConstraint?
    
    private lazy var contentView: UIView = UIView()
    private lazy var pageControlContianerView: UIView = UIView()
    private let visualBGView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private lazy var customLayoutView: CustomLayoutView = {
        let view = CustomLayoutView(frame: self.view.frame)
        return view
    }()
    
    private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
        scrollView.bounces = true
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isUserInteractionEnabled = true

        scrollView.contentInsetAdjustmentBehavior = .never
        
        let with = self.view.bounds.width * 16
        let hight = self.view.bounds.height
        scrollView.contentSize = CGSize(width: with, height: hight)

        return scrollView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .white.withAlphaComponent(0.6)
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.hidesForSinglePage = true
        pageControl.transform = CGAffineTransform.identity
        pageControl.addTarget(self, action: #selector(pageControlValueChanged(pageControl:)), for: .valueChanged)
        pageControl.accessibilityIdentifier = "PageControl"
    
        return pageControl
    }()
    
    init(meetingID: String) {
        super.init(nibName: nil, bundle: nil)
        self.meetingID = meetingID
        CustomLayoutViewController.customLayoutModel = CustomLayoutModel(meetingID: meetingID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configSubView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePageControlTotalPages()
        
        bindModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        CustomLayoutViewController.customLayoutModel?.setupVideoCanvas()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cancelable.removeAll()
        CustomLayoutViewController.customLayoutModel?.removeVideoCanvas()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func reload() {
        updatePageControlTotalPages()
        
        let beginIndex = self.currentPageIndex * perPageCount
        
        CustomLayoutViewController.customLayoutModel?.getSubParticipants(beginIndex: beginIndex)
    }
    
    private func pageChanged() {
        let beginIndex = self.currentPageIndex * perPageCount
        
        CustomLayoutViewController.customLayoutModel?.getSubParticipants(beginIndex: beginIndex)
    }
    
    @objc private func pageControlValueChanged(pageControl: UIPageControl) {
//        self.currentPageIndex = pageControl.currentPage
//
//        let beginIndex = self.currentPageIndex * perPageCount
//
//        CustomLayoutViewController.customLayoutModel?.getSubParticipants(beginIndex: beginIndex)
    }
    
    private func configSubView() {
        self.view.addSubview(self.scrollView)
        self.scrollView.makeConstraintsToBindToSuperview()
        
        self.view.addSubview(self.customLayoutView)
        self.customLayoutView.makeConstraintsToBindToSuperview()

        self.view.addSubview(pageControlContianerView)
        pageControlContianerView.translatesAutoresizingMaskIntoConstraints = false
        pageControlContianerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        pageControlContianerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        pageControlBottomConstraint = pageControlContianerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10)
        pageControlBottomConstraint?.isActive = true

        pageControlContianerView.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.makeConstraintsToBindToSuperview()

        pageControl.centerXAnchor.constraint(equalTo: pageControlContianerView.centerXAnchor).isActive = true
        pageControl.centerYAnchor.constraint(equalTo: pageControlContianerView.centerYAnchor).isActive = true

        self.view.bringSubviewToFront(self.scrollView)
    }
    
    private func bindModel() {
        cancelable.removeAll()

        CustomLayoutViewController.customLayoutModel?.$participantsList.sink { [weak self]
            participantsList in
            guard let self else { return }
            self.reload()
        }.store(in: &cancelable)
    }
    
    private func updatePageControlTotalPages() {
        guard let totalCount = CustomLayoutViewController.customLayoutModel?.totalCount() else {
            return
        }
        
        pageControl.numberOfPages = Int(ceilf(Float(totalCount) / Float(self.perPageCount)))
    }
    
    private func getParticipants(at index: Int)-> [RcvIParticipant] {
        guard let model = CustomLayoutViewController.customLayoutModel else {
            return []
        }
        
        if model.totalCount() == 0 {
            return []
        }
        var begin = index * perPageCount
        let end = min(begin + perPageCount, model.totalCount())
        guard begin < end else {
            return []
        }
        var subParticipants: [RcvIParticipant] = []
        while begin < end {
            let participant = model.cellForRowAtIndex(index: begin)
            subParticipants.append(participant!)
            begin = begin + 1
        }
        return subParticipants
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updatePageControlCurrentPage()
    }
    
    private func updatePageControlCurrentPage() {
        let pageWidth = scrollView.width
        if pageWidth > 0 {
            let curPage = Int(round(Float(scrollView.contentOffset.x) / Float(pageWidth)))
            pageControl.currentPage = curPage
            self.currentPageIndex = curPage
        }
    }
}
