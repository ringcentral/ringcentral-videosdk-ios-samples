//
//  UIFont+extension.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import Foundation
import UIKit
extension UIButton {
    func setMeetingIcon(_ name: GFIName, fontSize: CGFloat, textColor: UIColor, for state: UIControl.State = .normal) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "Arial", size: fontSize) as Any,
            .foregroundColor: textColor,
            .baselineOffset: 0.1,
        ]

        let str = NSAttributedString(string: name.rawValue, attributes: attributes)
        setAttributedTitle(str, for: state)
        titleLabel?.textAlignment = .center
    }
    
    func imageWithColor(_ color: UIColor) -> UIImage? {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        context?.setFillColor(color.cgColor)
        context?.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}

public extension UIFont {
    class func preferredFontMaximumSize(_ textStyle: UIFont.TextStyle) -> CGFloat {
        switch textStyle {
        case .largeTitle: return 44
        case .title1: return 38
        case .title2: return 34
        case .title3: return 31
        case .headline: return 28
        case .body: return 28
        case .callout: return 26
        case .subheadline: return 25
        case .footnote: return 23
        case .caption1: return 22
        case .caption2: return 20
        default: return 17
        }
    }
    
    class func preferredFontDefaultWeight(_ textStyle: UIFont.TextStyle) -> UIFont.Weight {
        switch textStyle {
        case .headline: return .semibold
        default: return .regular
        }
    }
    
    class func preferredFontDefaultSize(_ textStyle: UIFont.TextStyle) -> CGFloat {
        if textStyle == UIFont.TextStyle.largeTitle {
            return 34
        }
        switch textStyle {
        case .title1: return 28
        case .title2: return 22
        case .title3: return 20
        case .headline: return 17
        case .body: return 17
        case .callout: return 16
        case .subheadline: return 15
        case .footnote: return 13
        case .caption1: return 12
        case .caption2: return 11
        default: return 17
        }
    }
    
    func dynamicIfPossible(_ forTextStyle: UIFont.TextStyle) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: forTextStyle)
        return metrics.scaledFont(for: self, maximumPointSize: UIFont.preferredFontMaximumSize(forTextStyle))
    }
    
    class func limitedFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
        var font = UIFont.preferredFont(forTextStyle: style)
        if font.pointSize > preferredFontMaximumSize(style) {
            let fontSize = UIFont.preferredFontMaximumSize(style)
            let weight = UIFont.preferredFontDefaultWeight(style)
            font = UIFont.systemFont(ofSize: fontSize, weight: weight)
        }
        return font
    }
    
    class func boldPreferredFont(_ textStyle: UIFont.TextStyle, dynamic: Bool = true) -> UIFont {
        if dynamic {
            let fontSize = UIFont.preferredFontDefaultSize(textStyle)
            let standardFont = UIFont.boldSystemFont(ofSize: fontSize)
            return standardFont.dynamicIfPossible(textStyle)
        } else {
            let fontSize = UIFont.limitedFont(forTextStyle: textStyle).pointSize
            return UIFont.boldSystemFont(ofSize: fontSize)
        }
    }
}
