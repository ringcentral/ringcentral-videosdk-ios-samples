//
//  UIImage+extension.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import Foundation
import UIKit

@objc public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    func imageApplyColor(_ color: UIColor) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.translateBy(x: 0, y: size.height)
        ctx?.scaleBy(x: 1.0, y: -1.0)
        ctx?.setBlendMode(.normal)
        ctx?.clip(to: rect, mask: cgImage!)
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    static func fontAwesomeIcon(fontName: String? = nil, name: String, iconColor: UIColor, size: CGSize = .zero, fontSize: CGFloat, backgroundColor: UIColor = UIColor.clear, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.clear) -> UIImage {
        var imageSize = size
        if size.width <= 0 { imageSize.width = 1 }
        if size.height <= 0 { imageSize.height = 1 }

        let font = UIFont(name: "Arial", size: fontSize)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = NSTextAlignment.center

        // stroke width expects a whole number percentage of the font size
        let strokeWidth: CGFloat = -100 * borderWidth / fontSize

        let attributedString = NSAttributedString(string: name, attributes: [
            NSAttributedString.Key.font: font as Any,
            NSAttributedString.Key.foregroundColor: iconColor,
            NSAttributedString.Key.paragraphStyle: paragraph,
            NSAttributedString.Key.strokeWidth: strokeWidth,
            NSAttributedString.Key.strokeColor: borderColor,
        ])
        let stringSize = UIImage.sizeOfAttributedString(attributedString)
        if size == .zero {
            let imageSizeCompensationForZeroSize: CGFloat = 2
            imageSize = CGSize(width: ceil(stringSize.width) + imageSizeCompensationForZeroSize, height: ceil(stringSize.height) + imageSizeCompensationForZeroSize)
        } else {
            imageSize = CGSize(width: ceil(size.width), height: ceil(size.height))
        }

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(backgroundColor.cgColor)
            context.fill(CGRect(origin: .zero, size: imageSize))
            let stringRect = CGRect(x: (imageSize.width - stringSize.width) / 2, y: (imageSize.height - stringSize.height) / 2 - (font!.ascender - font!.capHeight + font!.descender) / 2, width: stringSize.width, height: stringSize.height)
            attributedString.draw(in: stringRect)
            let image = UIGraphicsGetImageFromCurrentImageContext()

            guard let realImage = image else { return UIImage() }
            return realImage
        } else {
            return UIImage()
        }
    }
    
    private static func sizeOfAttributedString(_ text: NSAttributedString) -> CGSize {
        if text.length == 0 {
            return CGSize(width: 10, height: 10)
        }

        let framesetter = CTFramesetterCreateWithAttributedString(text)
        let newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 0), nil, CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), nil)
        return newSize
    }
}
