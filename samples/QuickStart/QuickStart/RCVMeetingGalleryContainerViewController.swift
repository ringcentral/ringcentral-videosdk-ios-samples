//
//  RCVMeetingGalleryContainerViewController.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk


class RCVMeetingGalleryContainerViewController: UIViewController {
    private var cacheGalleryViewControllers: [RCVMeetingGalleryViewController] = []
    private(set) lazy var mainGalleryViewController = RCVMeetingGalleryViewController(withDelegate: self, isFirst: true)

    private var isMovingtoParent: Bool = false

    private var viewAppeared = false

    private let pageViewController = RCVMeetingPageViewController(navigationOrientation: .horizontal)
    private(set) var participantPerPage: Int = 3
    private var currentPageCount = 1

    private var debugEnabled: Bool = false
    public var participants: [RcvIParticipant] = []

    private lazy var pageDots: UIPageControl = {
        let dots = UIPageControl()
        dots.pageIndicatorTintColor = RCVColor.get(.neutralF01).withAlphaComponent(0.6)
        dots.currentPageIndicatorTintColor = RCVColor.get(.neutralF01)
        dots.hidesForSinglePage = true
        dots.addTarget(self, action: #selector(pageControlValueChanged(pageControl:)), for: .valueChanged)
        dots.accessibilityIdentifier = "GalleryPageControl"
        return dots
    }()

    private var pageDotsBottomConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        configPageViewController()
        configDots()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewAppeared = true
        currentViewController()?.endAppearanceTransition()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewAppeared = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
    }

    override func willMove(toParent parent: UIViewController?) {
        isMovingtoParent = true
        super.willMove(toParent: parent)
    }

    override func didMove(toParent parent: UIViewController?) {
        isMovingtoParent = false
        super.didMove(toParent: parent)
    }

    // MARK: - Public

    public func updatePage(_ current: Int, total: Int) {
        pageDots.numberOfPages = total
        pageDots.currentPage = current
    }

    func currentViewController() -> UIViewController? {
        return pageViewController.selectedViewController
    }

    // MARK: Private

    private func configDots() {
        pageDots.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageDots)
        pageDots.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        pageDots.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        pageDotsBottomConstraint = pageDots.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10.0)
        pageDotsBottomConstraint?.isActive = true
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()

        if view.safeAreaInsets.bottom > 0 {
            pageDotsBottomConstraint?.constant = -10
        } else {
            pageDotsBottomConstraint?.constant = 0
        }
    }

    @objc private func pageControlValueChanged(pageControl: UIPageControl) {
        let pageCount = galleryViewPageCount()
        let currentVC: RCVMeetingGalleryViewController
        if let tempVC = currentViewController() as? RCVMeetingGalleryViewController, pageCount > 1 {
            currentVC = tempVC
        } else {
            currentVC = mainGalleryViewController
        }
        let currentIndex = min(pageCount - 1, currentVC.pageIndex)
        if currentIndex < pageControl.currentPage {
            pageViewController.scrollForward(animated: false, completion: nil)
        } else if currentIndex > pageControl.currentPage {
            pageViewController.scrollReverse(animated: false, completion: nil)
        }
    }

    // MARK: Page View Controller

    private func configPageViewController() {
        pageViewController.delegate = self
        pageViewController.dataSource = self
        pageViewController.scrollView.bounces = false
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.makeConstraintsToBindToSuperview()
        scrollToHomePage(animated: false)
    }

    func scrollToHomePage(animated: Bool) {
        setCurrentViewController(mainGalleryViewController, isForward: true, animated: animated)
    }
}

// MARK: - <GalleryViewControllerDelegate>


extension RCVMeetingGalleryContainerViewController: GalleryViewControllerDelegate {
    func canOpenInFullscreen(participant: RcvIParticipant) -> Bool {
        return participant.status() == .ACTIVE
    }

    func didOpen(participant: RcvIParticipant?, from cell: RCVParticipantsListCell) {
        guard let model = participant else {
            return
        }
        if model.isMe() {
            return
        }

        guard canOpenInFullscreen(participant: model) else {
            return
        }
    }
}

// MARK: - <EMPageViewControllerDataSource, delegate>


extension RCVMeetingGalleryContainerViewController: EMPageViewControllerDataSource, EMPageViewControllerDelegate {
    func em_pageViewController(_ pageViewController: RCVMeetingPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = indexOfPage(viewController)
        if index > 0 {
            return pageController(at: index - 1)
        } else {
            return nil
        }
    }

    func em_pageViewController(_ pageViewController: RCVMeetingPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = indexOfPage(viewController)
        let pageCount = galleryViewPageCount()
        if index < pageCount - 1 {
            return pageController(at: index + 1)
        } else {
            return nil
        }
    }

    func em_pageViewController(_ pageViewController: RCVMeetingPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool) {
        defer {
            DispatchQueue.main.async {
                self.reloadPageData()
            }
        }
        guard transitionSuccessful else {
            return
        }
        if let galleryVC = destinationViewController as? RCVMeetingGalleryViewController {
            galleryVC.participants = getParticipants(at: galleryVC.pageIndex)
        }
    }

    func em_pageViewController(_ pageViewController: RCVMeetingPageViewController, willStartScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController) {
        
    }

    func em_pageViewController(_ pageViewController: RCVMeetingPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat) {

    }

    // screenSharing: -1, galleryView0: 0, galleryView1: 1
    private func indexOfPage(_ viewController: UIViewController) -> Int {
        if let galleryVC = viewController as? RCVMeetingGalleryViewController {
            return galleryVC.pageIndex
        } else {
            assert(false, "cannot get view controller")
            return 0
        }
    }

    private func pageController(at index: Int) -> UIViewController {
        assert(index >= 0)
        let controller: RCVMeetingGalleryViewController
        let usedViewControllers = pageViewController.viewControllers()
        if index == 0 {
            controller = mainGalleryViewController
        } else if let vc = cacheGalleryViewControllers.first(where: { !usedViewControllers.contains($0) }) {
            controller = vc
        } else {
            let temp = RCVMeetingGalleryViewController(withDelegate: self)
            cacheGalleryViewControllers.append(temp)
            controller = temp
        }
        assert(cacheGalleryViewControllers.count <= 3, "too much view controllers")
        controller.updatePage(index, total: galleryViewPageCount())
        controller.participants = getParticipants(at: index)
        return controller
    }

    func totalPageCount() -> Int {
        return galleryViewPageCount() + otherPageViewCount()
    }

    func otherPageViewCount() -> Int {
        return 0
    }

    func galleryViewPageCount() -> Int {
        let count = participants.count
        if count <= 0 {
            return 1
        }
        return Int(ceil(Double(count) / Double(participantPerPage)))
    }

    func getParticipants(at index: Int) -> [RcvIParticipant] {
        if participants.count == 0 {
            return []
        }
        var begin = index * participantPerPage
        let end = min(begin + participantPerPage, participants.count)
        guard begin < end else {
            return []
        }
        var subParticipants: [RcvIParticipant] = []
        while begin < end {
            subParticipants.append(participants[begin])
            begin = begin + 1
        }
        return subParticipants
    }
    
    func onParticipantsListUpdate() {
        reloadPageData()
    }

    func setCurrentViewController(_ viewController: UIViewController, isForward: Bool, animated: Bool) {
        let direction: EMPageViewControllerNavigationDirection = isForward ? .forward : .reverse
        pageViewController.selectViewController(viewController, direction: direction, animated: animated, completion: nil)
    }

    @discardableResult
    public func scrollForward() -> Bool {
        guard let currentVC = currentViewController() else {
            return false
        }
        guard let nextVC = em_pageViewController(pageViewController, viewControllerAfterViewController: currentVC) else {
            return false
        }
        pageViewController.selectViewController(nextVC, direction: .forward, animated: true, completion: nil)
        return true
    }

    @discardableResult
    public func scrollBackward() -> Bool {
        guard let currentVC = currentViewController() as? RCVMeetingGalleryViewController else {
            return false
        }
        guard let nextVC = em_pageViewController(pageViewController, viewControllerBeforeViewController: currentVC) else {
            return false
        }
        pageViewController.selectViewController(nextVC, direction: .reverse, animated: true, completion: nil)
        return true
    }
    
    func reloadPageData(_ participants: [RcvIParticipant]) {
        self.participants = participants
        reloadPageData()
    }

    func reloadPageData(force: Bool = false) {
        let pageCount = galleryViewPageCount()
        let currentVC: RCVMeetingGalleryViewController
        if let tempVC = currentViewController() as? RCVMeetingGalleryViewController, pageCount > 1 {
            currentVC = tempVC
        } else {
            currentVC = mainGalleryViewController
        }
        assert(pageCount > 0)
        let currentIndex = min(pageCount - 1, currentVC.pageIndex)
        let didChange = pageCount != currentPageCount || currentIndex != currentVC.pageIndex
        let participants = getParticipants(at: currentIndex)
        currentVC.updatePage(currentIndex, total: pageCount)
        updatePage(currentIndex, total: pageCount)
        currentVC.participants = participants
        currentPageCount = pageCount
        if currentViewController() == nil {
            return
        }

        // Do any additional setup after loading the view.
        if didChange || force {
            setCurrentViewController(currentVC, isForward: true, animated: false)
        }
    }
}
