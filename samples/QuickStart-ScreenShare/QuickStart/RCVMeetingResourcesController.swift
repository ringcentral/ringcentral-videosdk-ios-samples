//
//  RCVMeetingResourcesController.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 2/14/23.
//

import UIKit
import rcvsdk

protocol TransitionGestureRecognizerProtocol {
    var velocity: CGFloat { get }
    var direction: UIRectEdge { get }
    func completion(isEnded: Bool) -> CGFloat
}

extension TransitionGestureRecognizerProtocol where Self: UIPanGestureRecognizer {
    func completion(isEnded: Bool) -> CGFloat {
        guard let targetView = view else { return 0 }
        let windowWidth: CGFloat = targetView.bounds.size.width
        let transition: CGFloat
        if isEnded {
            transition = translation(in: targetView).x + velocity(in: targetView).x
        } else {
            transition = translation(in: targetView).x
        }
        switch direction {
        case .right:
            return transition >= 0 ? transition / windowWidth : 0
        case .left:
            return transition <= 0 ? -transition / windowWidth : 0
        default:
            return 0
        }
    }

    var velocity: CGFloat {
        guard let targetView = self.view else {
            return CGFloat(0)
        }
        let velocity = self.velocity(in: targetView)
        switch direction {
        case .right:
            return velocity.x >= 0 ? velocity.x : 0
        case .left:
            return velocity.x <= 0 ? -velocity.x : 0
        default:
            return 0
        }
    }
}

class ScreenEdgeTransitionGestureRecognizer: UIScreenEdgePanGestureRecognizer, TransitionGestureRecognizerProtocol {
    var direction: UIRectEdge {
        if edges.contains(.right) {
            return .left
        } else if edges.contains(.left) {
            return .right
        } else {
            return .right
        }
    }

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        maximumNumberOfTouches = 1
    }
}

class RCVTransitionManager: NSObject, UIViewControllerTransitioningDelegate {
    private var percentDrivenTransition: UIPercentDrivenInteractiveTransition?

    deinit {
        percentDrivenTransition?.cancel()
    }

    func begin() {
        percentDrivenTransition?.cancel()
        percentDrivenTransition = PercentDrivenInteractiveTransition()
    }

    func update(_ percentComplete: CGFloat) {
        percentDrivenTransition?.update(percentComplete)
    }

    func cancel() {
        percentDrivenTransition?.cancel()
        percentDrivenTransition = nil
    }

    func finish() {
        percentDrivenTransition?.finish()
        percentDrivenTransition = nil
    }
}

fileprivate class PercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    override var completionSpeed: CGFloat {
        set {}
        get {
            return min(1 - percentComplete, 0.5)
        }
    }
}

open class RCVTableViewSectionHeader: UITableViewHeaderFooterView {
    public static let reuseIdentifier = "RCVTableViewSectionHeader"
    open var backgroundImageView: UIImageView {
        return self._backgroundImageView
    }

    open var sectionTextLabel: UILabel!
    fileprivate var _backgroundImageView: UIImageView!

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        _init()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }

    fileprivate func _init() {
        _backgroundImageView = UIImageView()
        _backgroundImageView.backgroundColor = .clear//RCVColor.get(.neutralB02)
        backgroundView = _backgroundImageView

        sectionTextLabel = UILabel()
        sectionTextLabel.numberOfLines = 1
        sectionTextLabel.backgroundColor = UIColor.clear
        sectionTextLabel.textAlignment = NSTextAlignment.left
        sectionTextLabel.textColor = RCVColor.get(.neutralF05)
        sectionTextLabel.font = UIFont.boldPreferredFont(.footnote)
        sectionTextLabel.accessibilityTraits = .header
        contentView.addSubview(sectionTextLabel)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        sectionTextLabel.frame = CGRect(x: 16, y: 0, width: bounds.size.width - 32, height: bounds.size.height)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()

        sectionTextLabel.text = ""
    }
}

class ParticipantReactionsFilterHeader: UITableViewHeaderFooterView {
    var sectionTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.backgroundColor = UIColor.clear
        label.textAlignment = NSTextAlignment.left
        label.textColor = RCVColor.get(.neutralF05)
        label.font = UIFont.boldPreferredFont(.footnote)
        label.accessibilityTraits = .header
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear//RCVColor.get(.neutralB02)
        return imageView
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initSubView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSubView()
    }

    func initSubView() {
        backgroundView = backgroundImageView
        addSubview(sectionTextLabel)
        NSLayoutConstraint.activate([
            sectionTextLabel.leadingAnchor.constraint(equalTo: safeLeadingAnchor, constant: 16),
            sectionTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            sectionTextLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
        ])
    }
}

public enum RCVCustomActionSheetActionStyle: Int {
    case `default`
    case cancel
}

public enum CustomActionStyle: Int {
    case `default`
    case recentPhoto
    case attachPhoto
    case empty
}

public class RCVCustomActionSheetAction: NSObject {
    
    open var title: String?
    open var titleColor: UIColor?
    open var nImage: UIImage?
    open var style: RCVCustomActionSheetActionStyle
    
    public init(title: String?, nImage: UIImage?, style: RCVCustomActionSheetActionStyle) {
        self.title = title
        self.titleColor = RCVColor.get(.neutralF06)
        self.nImage = nImage
        self.style = style
        super.init()
    }
}

public enum GFIName: String, CaseIterable {
    case GFIMoreAction = "..."
    case GFIInvite = "+"
}


class RCVGestureNavigationController: UINavigationController {
    public var popGesture = UIPanGestureRecognizer()
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configFullScreenGesture()
        setupDefaultNavigationAppearance()
    }
    
    private func configFullScreenGesture() {
        let gesture = interactivePopGestureRecognizer
        gesture?.isEnabled = false
        let view = gesture?.view
        popGesture.delegate = self
        popGesture.maximumNumberOfTouches = 1
        view?.addGestureRecognizer(popGesture)
    }
    
    private func setupDefaultNavigationAppearance() {
        navigationBar.tintColor = RCVColor.get(.headerText)
        navigationBar.barTintColor = RCVColor.get(.headerBg)
        navigationBar.backgroundColor = RCVColor.get(.headerBg)
        navigationBar.setBackgroundImage(RCVColor.uiImageByColor(RCVColor.get(.headerBg)), for: .default)
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:  RCVColor.get(.headerText), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17.0)]
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false

        let normalTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: RCVColor.get(.headerText), NSAttributedString.Key.backgroundColor: RCVColor.get(.headerBg)]
        let hightedTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: RCVColor.get(.headerText), NSAttributedString.Key.backgroundColor: RCVColor.get(.headerBg)]
        let disableTitleAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: RCVColor.get(.headerText).withAlphaComponent(0.4), NSAttributedString.Key.backgroundColor: RCVColor.get(.headerBg)]

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: RCVColor.get(.headerText), .font: UIFont.boldSystemFont(ofSize: 17.0)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: RCVColor.get(.headerText), .font: UIFont.boldSystemFont(ofSize: 17.0)]

        let button = UIBarButtonItemAppearance(style: .plain)
        button.normal.titleTextAttributes = normalTitleAttributes
        button.highlighted.titleTextAttributes = hightedTitleAttributes
        button.disabled.titleTextAttributes = disableTitleAttributes
        navBarAppearance.buttonAppearance = button

        let done = UIBarButtonItemAppearance(style: .done)
        done.normal.titleTextAttributes = normalTitleAttributes
        done.highlighted.titleTextAttributes = hightedTitleAttributes
        done.disabled.titleTextAttributes = disableTitleAttributes
        navBarAppearance.doneButtonAppearance = done

        navBarAppearance.backgroundColor = RCVColor.get(.neutralB05)
        navBarAppearance.shadowColor = nil
        navBarAppearance.shadowImage = nil
        navigationBar.titleTextAttributes = navBarAppearance.titleTextAttributes
        navigationBar.standardAppearance = navBarAppearance
        navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationBar.compactAppearance = navBarAppearance
    }
}

extension RCVGestureNavigationController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == popGesture {
            var recongnize = false
            if let isTransitioning = value(forKey: "_isTransitioning") as? NSNumber {
                recongnize = viewControllers.count > 1 && !isTransitioning.boolValue
            }
            let translation = popGesture.translation(in: popGesture.view)
            let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == UIUserInterfaceLayoutDirection.leftToRight
            let multiplier: CGFloat = isLeftToRight ? 1.0 : -1.0
            let isLeft = (translation.x * multiplier > 0.0)
            return recongnize && isLeft
        }
        if gestureRecognizer == interactivePopGestureRecognizer {
            var recongnize = false
            if let isTransitioning = value(forKey: "_isTransitioning") as? NSNumber {
                recongnize = viewControllers.count > 1 && !isTransitioning.boolValue
            }
            return recongnize
        }
        return false
    }
}
