//
//  File.swift
//  
//
//  Created by Chongshen Wu on 2023/2/23.
//

import Foundation
import rcvsdk

@available(iOS 13.0, *)
@objc public protocol EMPageViewControllerDataSource {
    /**
     Called to optionally return a view controller that is to the left of a given view controller in a horizontal orientation, or above a given view controller in a vertical orientation.

     - parameter pageViewController: The page view controller
     - parameter viewController: The point of reference view controller

     - returns: The view controller that is to the left of the given `viewController` in a horizontal orientation, or above the given `viewController` in a vertical orientation, or `nil` if there is no view controller to be displayed.
     */
    func em_pageViewController(_ pageViewController: RCVMeetingPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?

    /**
     Called to optionally return a view controller that is to the right of a given view controller.

     - parameter pageViewController: The page view controller
     - parameter viewController: The point of reference view controller

     - returns: The view controller that is to the right of the given `viewController` in a horizontal orientation, or below the given `viewController` in a vertical orientation, or `nil` if there is no view controller to be displayed.
     */
    func em_pageViewController(_ pageViewController: RCVMeetingPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
}

/**
 The EMPageViewControllerDelegate protocol is adopted to receive messages for all important events of the page transition process.
 */
@available(iOS 13.0, *)
@objc public protocol EMPageViewControllerDelegate {
    /**
     Called before scrolling to a new view controller.

     - note: This method will not be called if the starting view controller is `nil`. A common scenario where this will occur is when you initialize the page view controller and use `selectViewController:direction:animated:completion:` to load the first selected view controller.

     - important: If bouncing is enabled, it is possible this method will be called more than once for one page transition. It can be called before the initial scroll to the destination view controller (which is when it is usually called), and it can also be called when the scroll momentum carries over slightly to the view controller after the original destination view controller.

     - parameter pageViewController: The page view controller
     - parameter startingViewController: The currently selected view controller the transition is starting from
     - parameter destinationViewController: The view controller that will be scrolled to, where the transition should end
     */
    @objc optional func em_pageViewController(_ pageViewController: RCVMeetingPageViewController, willStartScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController)

    /**
     Called whenever there has been a scroll position change in a page transition. This method is very useful if you need to know the exact progress of the page transition animation.

     - note: This method will not be called if the starting view controller is `nil`. A common scenario where this will occur is when you initialize the page view controller and use `selectViewController:direction:animated:completion:` to load the first selected view controller.

     - parameter pageViewController: The page view controller
     - parameter startingViewController: The currently selected view controller the transition is starting from
     - parameter destinationViewController: The view controller being scrolled to where the transition should end
     - parameter progress: The progress of the transition, where 0 is a neutral scroll position, >= 1 is a complete transition to the right view controller in a horizontal orientation, or the below view controller in a vertical orientation, and <= -1 is a complete transition to the left view controller in a horizontal orientation, or the above view controller in a vertical orientation. Values may be greater than 1 or less than -1 if bouncing is enabled and the scroll velocity is quick enough.
     */
    @objc optional func em_pageViewController(_ pageViewController: RCVMeetingPageViewController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController?, progress: CGFloat)

    /**
     Called after a page transition attempt has completed.

     - important: If bouncing is enabled, it is possible this method will be called more than once for one page transition. It can be called after the scroll transition to the intended destination view controller (which is when it is usually called), and it can also be called when the scroll momentum carries over slightly to the view controller after the intended destination view controller. In the latter scenario, `transitionSuccessful` will return `false` the second time it's called because the scroll view will bounce back to the intended destination view controller.

     - parameter pageViewController: The page view controller
     - parameter startingViewController: The currently selected view controller the transition is starting from
     - parameter destinationViewController: The view controller that has been attempted to be selected
     - parameter transitionSuccessful: A Boolean whether the transition to the destination view controller was successful or not. If `true`, the new selected view controller is `destinationViewController`. If `false`, the transition returned to the view controller it started from, so the selected view controller is still `startingViewController`.
     */
    @objc optional func em_pageViewController(_ pageViewController: RCVMeetingPageViewController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool)
}

/**
 The navigation scroll direction.
 */
@objc public enum EMPageViewControllerNavigationDirection: Int {
    /// Forward direction. Can be right in a horizontal orientation or down in a vertical orientation.
    case forward
    /// Reverse direction. Can be left in a horizontal orientation or up in a vertical orientation.
    case reverse
}

/**
 The navigation scroll orientation.
 */
@objc public enum EMPageViewControllerNavigationOrientation: Int {
    /// Horiziontal orientation. Scrolls left and right.
    case horizontal
    /// Vertical orientation. Scrolls up and down.
    case vertical
}

/// Manages page navigation between view controllers. View controllers can be navigated via swiping gestures, or called programmatically.
@available(iOS 13.0, *)
open class RCVMeetingPageViewController: UIViewController, UIScrollViewDelegate {
    /// The object that provides view controllers on an as-needed basis throughout the navigation of the page view controller.
    ///
    /// If the data source is `nil`, gesture based scrolling will be disabled and all view controllers must be provided through `selectViewController:direction:animated:completion:`.
    ///
    /// - important: If you are using a data source, make sure you set `dataSource` before calling `selectViewController:direction:animated:completion:`.
    open weak var dataSource: EMPageViewControllerDataSource?

    /// The object that receives messages throughout the navigation process of the page view controller.
    open weak var delegate: EMPageViewControllerDelegate?

    /// The direction scrolling navigation occurs
    open private(set) var navigationOrientation: EMPageViewControllerNavigationOrientation = .horizontal

    private var isOrientationHorizontal: Bool {
        return self.navigationOrientation == .horizontal
    }

    /// The underlying `UIScrollView` responsible for scrolling page views.
    /// - important: Properties should be set with caution to prevent unexpected behavior.
    open private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.scrollsToTop = false
        scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = self.isOrientationHorizontal
        scrollView.alwaysBounceVertical = !self.isOrientationHorizontal
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        scrollView.contentInsetAdjustmentBehavior = .never

        return scrollView
    }()

    /// The view controller before the selected view controller.
    var beforeViewController: UIViewController?

    /// The currently selected view controller. Can be `nil` if no view controller is selected.
    open private(set) var selectedViewController: UIViewController?

    /// The view controller after the selected view controller.
    var afterViewController: UIViewController?

    /// Boolean that indicates whether the page controller is currently in the process of scrolling.
    open private(set) var scrolling = false

    /// The direction the page controller is scrolling towards.
    open private(set) var navigationDirection: EMPageViewControllerNavigationDirection?

    private var adjustingContentOffset = false // Flag used to prevent isScrolling delegate when shifting scrollView
    private var loadNewAdjoiningViewControllersOnFinish = false
    private var didFinishScrollingCompletionHandler: ((_ transitionSuccessful: Bool) -> Void)?
    private var transitionAnimated = false // Used for accurate view appearance messages

    // MARK: - Public Methods

    /// Initializes a newly created page view controller with the specified navigation orientation.
    /// - parameter navigationOrientation: The page view controller's navigation scroll direction.
    /// - returns: The initialized page view controller.
    public convenience init(navigationOrientation: EMPageViewControllerNavigationOrientation) {
        self.init()
        self.navigationOrientation = navigationOrientation
    }

    /**
     Sets the view controller that will be selected after the animation. This method is also used to provide the first view controller that will be selected in the page view controller.

     If a data source has been set, the view controllers before and after the selected view controller will also be loaded but not appear yet.

     - important: If you are using a data source, make sure you set `dataSource` before calling `selectViewController:direction:animated:completion:`

     - parameter viewController: The view controller to be selected.
     - parameter direction: The direction of the navigation and animation, if applicable.
     - parameter completion: A block that's called after the transition is finished. The block parameter `transitionSuccessful` is `true` if the transition to the selected view controller was completed successfully.
     */
    open func selectViewController(_ viewController: UIViewController, direction: EMPageViewControllerNavigationDirection, animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        if viewController == selectedViewController {
            // fix
            beforeViewController = nil
            loadBeforeViewController(for: viewController)
            afterViewController = nil
            loadAfterViewController(for: viewController)
            layoutViews()
            return
        }

        if direction == .forward {
            afterViewController = viewController
            layoutViews()
            loadNewAdjoiningViewControllersOnFinish = true
            scrollForward(animated: animated, completion: completion)
        } else if direction == .reverse {
            beforeViewController = viewController
            layoutViews()
            loadNewAdjoiningViewControllersOnFinish = true
            scrollReverse(animated: animated, completion: completion)
        }
    }

    open func removeAllViewControllers() {
        removeChildIfNeeded(beforeViewController)
        removeChildIfNeeded(selectedViewController)
        removeChildIfNeeded(afterViewController)

        beforeViewController = nil
        selectedViewController = nil
        afterViewController = nil
    }

    open func viewControllers() -> [UIViewController] {
        return [beforeViewController, selectedViewController, afterViewController].compactMap { $0 }
    }

    /**
     Transitions to the view controller right of the currently selected view controller in a horizontal orientation, or below the currently selected view controller in a vertical orientation. Also described as going to the next page.

     - parameter animated: A Boolean whether or not to animate the transition
     - parameter completion: A block that's called after the transition is finished. The block parameter `transitionSuccessful` is `true` if the transition to the selected view controller was completed successfully. If `false`, the transition returned to the view controller it started from.
     */
    @objc(scrollForwardAnimated:completion:)
    open func scrollForward(animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        if afterViewController != nil {
            // Cancel current animation and move
            if scrolling {
                if isOrientationHorizontal {
                    scrollView.setContentOffset(CGPoint(x: view.bounds.width * 2, y: 0), animated: false)
                } else {
                    scrollView.setContentOffset(CGPoint(x: 0, y: view.bounds.height * 2), animated: false)
                }
            }

            didFinishScrollingCompletionHandler = completion
            transitionAnimated = animated
            if isOrientationHorizontal {
                scrollView.setContentOffset(CGPoint(x: view.bounds.width * 2, y: 0), animated: animated)
            } else {
                scrollView.setContentOffset(CGPoint(x: 0, y: view.bounds.height * 2), animated: animated)
            }
        }
    }

    /**
     Transitions to the view controller left of the currently selected view controller in a horizontal orientation, or above the currently selected view controller in a vertical orientation. Also described as going to the previous page.

     - parameter animated: A Boolean whether or not to animate the transition
     - parameter completion: A block that's called after the transition is finished. The block parameter `transitionSuccessful` is `true` if the transition to the selected view controller was completed successfully. If `false`, the transition returned to the view controller it started from.
     */
    @objc(scrollReverseAnimated:completion:)
    open func scrollReverse(animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        if beforeViewController != nil {
            // Cancel current animation and move
            if scrolling {
                scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }

            didFinishScrollingCompletionHandler = completion
            transitionAnimated = animated
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
        }
    }

    @nonobjc @available(*, unavailable, renamed: "scrollForward(animated:completion:)")
    open func scrollForwardAnimated(_ animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        scrollForward(animated: animated, completion: completion)
    }

    @nonobjc @available(*, unavailable, renamed: "scrollReverse(animated:completion:)")
    open func scrollReverseAnimated(_ animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
        scrollReverse(animated: animated, completion: completion)
    }

    // MARK: - View Controller Overrides

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedViewController = selectedViewController {
            selectedViewController.beginAppearanceTransition(true, animated: animated)
        }
    }

    private var didViewAppear: Bool = false

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didViewAppear = true
        if let selectedViewController = selectedViewController {
            selectedViewController.endAppearanceTransition()
        }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let selectedViewController = selectedViewController {
            selectedViewController.beginAppearanceTransition(false, animated: animated)
        }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didViewAppear = false
        if let selectedViewController = selectedViewController {
            selectedViewController.endAppearanceTransition()
        }
    }

    // Overriden to have control of accurate view appearance method calls
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        view.addSubview(scrollView)
    }

    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        adjustingContentOffset = true

        scrollView.frame = view.bounds
        if isOrientationHorizontal {
            scrollView.contentSize = CGSize(width: view.bounds.width * 3, height: view.bounds.height)
        } else {
            scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height * 3)
        }

        layoutViews()
    }

    // MARK: - View Controller Management

    private func loadViewControllers(_ selectedViewController: UIViewController) {
        // Scrolled forward
        if selectedViewController == afterViewController {
            // Shift view controllers forward
            beforeViewController = self.selectedViewController
            self.selectedViewController = afterViewController

            removeChildIfNeeded(beforeViewController)

            if didViewAppear {
                self.selectedViewController?.endAppearanceTransition()
                beforeViewController?.endAppearanceTransition()
            }

            delegate?.em_pageViewController?(self, didFinishScrollingFrom: beforeViewController, destinationViewController: self.selectedViewController!, transitionSuccessful: true)

            didFinishScrollingCompletionHandler?(true)
            didFinishScrollingCompletionHandler = nil

            // Load new before view controller if required
            if loadNewAdjoiningViewControllersOnFinish {
                loadBeforeViewController(for: selectedViewController)
                loadNewAdjoiningViewControllersOnFinish = false
            }

            // Load new after view controller
            loadAfterViewController(for: selectedViewController)

            // Scrolled reverse
        } else if selectedViewController == beforeViewController {
            // Shift view controllers reverse
            afterViewController = self.selectedViewController
            self.selectedViewController = beforeViewController

            removeChildIfNeeded(afterViewController)

            if didViewAppear {
                self.selectedViewController?.endAppearanceTransition()
                afterViewController?.endAppearanceTransition()
            }

            delegate?.em_pageViewController?(self, didFinishScrollingFrom: afterViewController!, destinationViewController: self.selectedViewController!, transitionSuccessful: true)

            didFinishScrollingCompletionHandler?(true)
            didFinishScrollingCompletionHandler = nil

            // Load new after view controller if required
            if loadNewAdjoiningViewControllersOnFinish {
                loadAfterViewController(for: selectedViewController)
                loadNewAdjoiningViewControllersOnFinish = false
            }

            // Load new before view controller
            loadBeforeViewController(for: selectedViewController)

            // Scrolled but ended up where started
        } else if selectedViewController == self.selectedViewController {
            self.selectedViewController!.beginAppearanceTransition(true, animated: transitionAnimated)

            if navigationDirection == .forward {
                afterViewController!.beginAppearanceTransition(false, animated: transitionAnimated)
            } else if navigationDirection == .reverse {
                beforeViewController!.beginAppearanceTransition(false, animated: transitionAnimated)
            }

            if didViewAppear {
                self.selectedViewController?.endAppearanceTransition()
            }

            // Remove hidden view controllers
            removeChildIfNeeded(beforeViewController)
            removeChildIfNeeded(afterViewController)

            if navigationDirection == .forward {
                afterViewController!.endAppearanceTransition()
                delegate?.em_pageViewController?(self, didFinishScrollingFrom: self.selectedViewController!, destinationViewController: afterViewController!, transitionSuccessful: false)
            } else if navigationDirection == .reverse {
                beforeViewController!.endAppearanceTransition()
                delegate?.em_pageViewController?(self, didFinishScrollingFrom: self.selectedViewController!, destinationViewController: beforeViewController!, transitionSuccessful: false)
            } else {
                delegate?.em_pageViewController?(self, didFinishScrollingFrom: self.selectedViewController!, destinationViewController: self.selectedViewController!, transitionSuccessful: true)
            }

            didFinishScrollingCompletionHandler?(false)
            didFinishScrollingCompletionHandler = nil

            if loadNewAdjoiningViewControllersOnFinish {
                if navigationDirection == .forward {
                    loadAfterViewController(for: selectedViewController)
                } else if navigationDirection == .reverse {
                    loadBeforeViewController(for: selectedViewController)
                }
            }
        }

        navigationDirection = nil
        scrolling = false
    }

    private func loadBeforeViewController(for selectedViewController: UIViewController) {
        // Retreive the new before controller from the data source if available, otherwise set as nil
        if let beforeViewController = self.dataSource?.em_pageViewController(self, viewControllerBeforeViewController: selectedViewController) {
            self.beforeViewController = beforeViewController
        } else {
            beforeViewController = nil
        }
    }

    private func loadAfterViewController(for selectedViewController: UIViewController) {
        // Retreive the new after controller from the data source if available, otherwise set as nil
        if let afterViewController = self.dataSource?.em_pageViewController(self, viewControllerAfterViewController: selectedViewController) {
            self.afterViewController = afterViewController
        } else {
            afterViewController = nil
        }
    }

    // MARK: - View Management

    private func addChildIfNeeded(_ viewController: UIViewController) {
        scrollView.addSubview(viewController.view)

        #if swift(>=4.2)
            addChild(viewController)
            viewController.didMove(toParent: self)
        #else
            addChildViewController(viewController)
            viewController.didMove(toParentViewController: self)
        #endif
    }

    private func removeChildIfNeeded(_ viewController: UIViewController?) {
        viewController?.view.removeFromSuperview()

        #if swift(>=4.2)
            viewController?.didMove(toParent: nil)
            viewController?.removeFromParent()
        #else
            viewController?.didMove(toParentViewController: nil)
            viewController?.removeFromParentViewController()
        #endif
    }

    private func layoutViews() {
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height

        var beforeInset: CGFloat = 0
        var afterInset: CGFloat = 0

        if beforeViewController == nil {
            beforeInset = isOrientationHorizontal ? -viewWidth : -viewHeight
        }

        if afterViewController == nil {
            afterInset = isOrientationHorizontal ? -viewWidth : -viewHeight
        }

        adjustingContentOffset = true
        scrollView.contentOffset = CGPoint(x: isOrientationHorizontal ? viewWidth : 0, y: isOrientationHorizontal ? 0 : viewHeight)
        if isOrientationHorizontal {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: beforeInset, bottom: 0, right: afterInset)
        } else {
            scrollView.contentInset = UIEdgeInsets(top: beforeInset, left: 0, bottom: afterInset, right: 0)
        }
        adjustingContentOffset = false

        if isOrientationHorizontal {
            beforeViewController?.view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            selectedViewController?.view.frame = CGRect(x: viewWidth, y: 0, width: viewWidth, height: viewHeight)
            afterViewController?.view.frame = CGRect(x: viewWidth * 2, y: 0, width: viewWidth, height: viewHeight)
        } else {
            beforeViewController?.view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
            selectedViewController?.view.frame = CGRect(x: 0, y: viewHeight, width: viewWidth, height: viewHeight)
            afterViewController?.view.frame = CGRect(x: 0, y: viewHeight * 2, width: viewWidth, height: viewHeight)
        }
    }

    // MARK: - Internal Callbacks

    private func willScroll(from startingViewController: UIViewController?, to destinationViewController: UIViewController) {
        if startingViewController != nil {
            delegate?.em_pageViewController?(self, willStartScrollingFrom: startingViewController!, destinationViewController: destinationViewController)
        }

        destinationViewController.beginAppearanceTransition(true, animated: transitionAnimated)
        startingViewController?.beginAppearanceTransition(false, animated: transitionAnimated)
        addChildIfNeeded(destinationViewController)
    }

    private func didFinishScrolling(to viewController: UIViewController) {
        loadViewControllers(viewController)
        layoutViews()
    }

    // MARK: - UIScrollView Delegate

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !adjustingContentOffset {
            let distance = isOrientationHorizontal ? view.bounds.width : view.bounds.height
            let progress = ((isOrientationHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y) - distance) / distance

            // Scrolling forward / after
            if progress > 0 {
                if let afterViewController = afterViewController {
                    if !scrolling { // call willScroll once
                        willScroll(from: selectedViewController, to: afterViewController)
                        scrolling = true
                    }

                    if let selectedViewController = selectedViewController,
                        self.navigationDirection == .reverse { // check if direction changed
                        didFinishScrolling(to: selectedViewController)
                        willScroll(from: selectedViewController, to: afterViewController)
                    }

                    navigationDirection = .forward

                    if let selectedViewController = selectedViewController {
                        delegate?.em_pageViewController?(self, isScrollingFrom: selectedViewController, destinationViewController: afterViewController, progress: progress)
                    }
                } else {
                    if let selectedViewController = selectedViewController {
                        delegate?.em_pageViewController?(self,
                                                         isScrollingFrom: selectedViewController,
                                                         destinationViewController: nil,
                                                         progress: progress)
                    }
                }

                // Scrolling reverse / before
            } else if progress < 0 {
                if let beforeViewController = beforeViewController {
                    if !scrolling { // call willScroll once
                        willScroll(from: selectedViewController, to: beforeViewController)
                        scrolling = true
                    }

                    if let selectedViewController = selectedViewController,
                        self.navigationDirection == .forward { // check if direction changed
                        didFinishScrolling(to: selectedViewController)
                        willScroll(from: selectedViewController, to: beforeViewController)
                    }

                    navigationDirection = .reverse

                    if let selectedViewController = selectedViewController {
                        delegate?.em_pageViewController?(self, isScrollingFrom: selectedViewController, destinationViewController: beforeViewController, progress: progress)
                    }
                } else {
                    if let selectedViewController = selectedViewController {
                        delegate?.em_pageViewController?(self,
                                                         isScrollingFrom: selectedViewController,
                                                         destinationViewController: nil,
                                                         progress: progress)
                    }
                }

                // At zero
            } else {
                if navigationDirection == .forward {
                    delegate?.em_pageViewController?(self, isScrollingFrom: selectedViewController!, destinationViewController: afterViewController!, progress: progress)
                } else if navigationDirection == .reverse {
                    delegate?.em_pageViewController?(self, isScrollingFrom: selectedViewController!, destinationViewController: beforeViewController!, progress: progress)
                }
            }

            // Thresholds to update view layouts call delegates
            if progress >= 1 && afterViewController != nil {
                didFinishScrolling(to: afterViewController!)
            } else if progress <= -1 && beforeViewController != nil {
                didFinishScrolling(to: beforeViewController!)
            } else if progress == 0 && selectedViewController != nil {
                didFinishScrolling(to: selectedViewController!)
            }
        }
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        transitionAnimated = true
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // setContentOffset is called to center the selected view after bounces
        // This prevents yucky behavior at the beginning and end of the page collection by making sure setContentOffset is called only if...

        if isOrientationHorizontal {
            if (beforeViewController != nil && afterViewController != nil) || // It isn't at the beginning or end of the page collection
                (afterViewController != nil && beforeViewController == nil && scrollView.contentOffset.x > abs(scrollView.contentInset.left)) || // If it's at the beginning of the collection, the decelleration can't be triggered by scrolling away from, than torwards the inset
                (beforeViewController != nil && afterViewController == nil && scrollView.contentOffset.x < abs(scrollView.contentInset.right)) { // Same as the last condition, but at the end of the collection
                scrollView.setContentOffset(CGPoint(x: view.bounds.width, y: 0), animated: true)
            }
        } else {
            if (beforeViewController != nil && afterViewController != nil) || // It isn't at the beginning or end of the page collection
                (afterViewController != nil && beforeViewController == nil && scrollView.contentOffset.y > abs(scrollView.contentInset.top)) || // If it's at the beginning of the collection, the decelleration can't be triggered by scrolling away from, than torwards the inset
                (beforeViewController != nil && afterViewController == nil && scrollView.contentOffset.y < abs(scrollView.contentInset.bottom)) { // Same as the last condition, but at the end of the collection
                scrollView.setContentOffset(CGPoint(x: 0, y: view.bounds.height), animated: true)
            }
        }
    }
}
