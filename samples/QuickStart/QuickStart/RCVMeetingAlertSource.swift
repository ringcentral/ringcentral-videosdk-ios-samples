//
//  RCVMeetingAlertSource.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

open class RCVMeetingAlertController: UIAlertController,  UIPopoverPresentationControllerDelegate{
    open var didDismissBlock: (() -> Void)?
    var additionObject: AnyObject?
    var dismissAciton: RCVMeetingAlertAction?
    
    open func addAction(_ action: RCVMeetingAlertAction) {
        if action.title != nil {
            let alertAction = UIAlertAction(title: action.title!, style: action.style, handler: { [weak self] (tempAction: UIAlertAction) -> Void in
                if let handler = action.handler {
                    handler(action)
                }

                if let didDismissBlock = self?.didDismissBlock {
                    //didDismissBlock()
                }

                if tempAction.style == .cancel {
                    //AccessibilityFocusManager.shared.backToTrigger()
                }
            })

            super.addAction(alertAction)
            if action.isPreferredAction {
                preferredAction = alertAction
            }
        }

        if action.style == UIAlertAction.Style.cancel {
            dismissAciton = action
        }
    }
    
    open func showAlertController(_ viewController: UIViewController, handler: (() -> Void)?) {
        //MedalliaSDKManager.shared.disableInterceptMedallia()
        if let popoverController = self.popoverPresentationController {
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = viewController.view.frame
            popoverController.delegate = self
        }
        viewController.present(self, animated: true, completion: handler)
    }
    
    open func alertID() -> Int {
        return hashValue
    }
}

open class RCVMeetingAlertAction {
    open var title: String?
    open var style: UIAlertAction.Style
    open var handler: ((RCVMeetingAlertAction) -> Void)?
    open var isPreferredAction: Bool = false

    public init(title: String?, style: UIAlertAction.Style, handler: ((RCVMeetingAlertAction) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }

    deinit {
        return
    }
}

public class OverlayWindowManager {
    public static let shared = OverlayWindowManager()
    
    public var mainWindow: UIWindow?
    
    public let overlayWindow: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = UIWindow.Level.callWindowLevel
        window.isHidden = true
        window.rootViewController = UIViewController()
        return window
    }()
}

public extension UIWindow.Level {
    static let callWindowLevel: UIWindow.Level = UIWindow.Level.normal + 0.5
    static let notificationWindowLevel: UIWindow.Level = UIWindow.Level.callWindowLevel - 0.1
    static let menuWindowLevel: UIWindow.Level = UIWindow.Level.callWindowLevel + 0.01
}

public class RootController {
    public static let shared = RootController()
    public var window: UIWindow?
    
    public func rootViewController(on window: UIWindow? = RootController.shared.window) -> UIViewController? {
        //return window?.rootViewController
        let rootViewController = window?.rootViewController
        return rootViewController
    }
    
    public func modalViewController(on window: UIWindow? = RootController.shared.window) -> UIViewController {
        var viewController: UIViewController?
            if !OverlayWindowManager.shared.overlayWindow.isHidden {
                viewController = rootViewController(on: OverlayWindowManager.shared.overlayWindow)
            } else {
                viewController = rootViewController(on: window)
            }

        while let presentedViewController = viewController?.presentedViewController {
            viewController = presentedViewController
        }

        return viewController ?? rootViewController()!
    }
}

open class RCVMeetingAlertManager: NSObject {
    public var glipAlerts: [RCVMeetingAlertController] { return alertStore.allObjects }

    var alertStore = NSHashTable<RCVMeetingAlertController>.weakObjects()
    public static var sharedInstance = RCVMeetingAlertManager()

    @discardableResult
    open func showAlertOfTitle(_ title: String?, text: String?, style: UIAlertController.Style, actions: [RCVMeetingAlertAction], viewController: UIViewController, additionObject: AnyObject?, completion: (() -> Void)?) -> Int {
        let alertController = RCVMeetingAlertController(title: title, message: text, preferredStyle: style)

        alertController.didDismissBlock = { [weak self, weak alertController] in
            if let alertController = alertController {
                self?.alertStore.remove(alertController)
            }
        }

        for action in actions {
            alertController.addAction(action)
        }

        alertStore.add(alertController)

        alertController.showAlertController(viewController, handler: completion)

        return alertController.alertID()
    }

//    open func dismissAllAlertsWithAnimated(_ animated: Bool) {
//        glipAlerts.reversed().forEach {
//            $0.dismissWithAnimated(animated)
//        }
//    }
//
//    open func dismissAlertWithID(_ ID: Int, animated: Bool) {
//        for alert in glipAlerts where alert.alertID() == ID {
//            alert.dismissWithAnimated(animated)
//            return
//        }
//    }

    open func additionObjectWithAlertID(_ ID: Int) -> AnyObject? {
        for alert in glipAlerts {
            if alert.alertID() == ID {
                return alert.additionObject
            }
        }

        return nil
    }

    open func isAlertsExist() -> Bool {
        return !glipAlerts.isEmpty
    }

    open func checkExist(alertID: Int) -> Bool {
        return glipAlerts.first { $0.alertID() == alertID } != nil
    }
}
