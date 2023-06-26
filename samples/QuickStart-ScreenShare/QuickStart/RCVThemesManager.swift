//
//  RCVThemesManager.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

let RCV_THEMES_NAME = "themes"

public class RCVThemesManager{
    public static let shared = RCVThemesManager()
    public var themesInfo: [String: Any]?
    private var themes: [RCVSampleThemes] = []
    private var themeGroup: (light: RCVSampleThemes, dark: RCVSampleThemes)?
    
    public func updateDefaultTheme() {
        if let themesPath = Bundle.main.path(forResource: RCV_THEMES_NAME, ofType: "json") {
            self.themesInfo = jsonWithPath(path: themesPath)
        }
    }
    
    private func jsonWithPath(path: String) -> [String: Any]? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
        } catch {
            return nil
        }
    }
    
    public func deployThemesInfo() {
        updateDefaultTheme()
        guard let rcvThemesInfo = self.themesInfo else {
            return
        }
        
        if let themesFromFile = rcvThemesInfo["themes"] as? [[String: Any]] {
            themes = themesFromFile.map({
                RCVSampleThemes(dictionary: $0)
            }).sorted(by: {
                $0.priority < $1.priority
            })
        }
        
        guard themes.count > 0 else {
            return
        }
        
        if let light = themes.first(where: { $0.themeType == .light }), let dark = themes.first(where: { $0.themeType == .dark }) {
            themeGroup = (light, dark)
        } else {
            themes.forEach { print("Name: \($0.themeName), Type: \($0.themeType)") }
        }
    }
    
    public func getColor(key: String) -> UIColor? {
        guard let lightTheme = themeGroup?.light, let darkTheme = themeGroup?.dark else {
            return nil
        }
        struct ColorInfo {
            let hex: String
            let alpha: CGFloat
            let highContrastHex: String?
            let highContrastAlpha: Double?
            var hcHex: String {
                return highContrastHex ?? hex
            }

            var hcAlpha: CGFloat {
                return highContrastAlpha ?? alpha
            }
        }
        if let lightColorHex = lightTheme.themeDefault.getHex(key), let darkColorHex = darkTheme.themeDefault.getHex(key) {
            let lightInfo = ColorInfo(hex: lightColorHex,
                                      alpha: lightTheme.themeDefault.getAlpha(key) ?? 1.0,
                                      highContrastHex: lightTheme.highContrast.getHex(key),
                                      highContrastAlpha: lightTheme.highContrast.getAlpha(key))

            let darkInfo = ColorInfo(hex: darkColorHex,
                                     alpha: darkTheme.themeDefault.getAlpha(key) ?? 1.0,
                                     highContrastHex: darkTheme.highContrast.getHex(key),
                                     highContrastAlpha: darkTheme.highContrast.getAlpha(key))
            return UIColor { (traitCollection: UITraitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .light {
                    if traitCollection.accessibilityContrast == .high {
                        return UIColor(hex: lightInfo.hcHex).withAlphaComponent(lightInfo.hcAlpha)
                    } else {
                        return UIColor(hex: lightInfo.hex).withAlphaComponent(lightInfo.alpha)
                    }
                } else {
                    if traitCollection.accessibilityContrast == .high {
                        return UIColor(hex: darkInfo.hcHex).withAlphaComponent(darkInfo.hcAlpha)
                    } else {
                        return UIColor(hex: darkInfo.hex).withAlphaComponent(darkInfo.alpha)
                    }
                }
            }
        } else {
            return nil
        }
    }
}

public enum RCVThemeType: Int {
    case light = 0
    case dark
}

public struct RCVColorPalette {
    public var alias: [String: String]
    public var hex: [String: String]
    public var alpha: [String: Double]
    
    init(dictionary: [String: Any]) {
        alias = (dictionary["alias"] as? [String: String]) ?? [:]
        hex = (dictionary["hex"] as? [String: String]) ?? [:]
        alpha = (dictionary["alpha"] as? [String: Double]) ?? [:]
    }
    
    func getHex(_ aliasKey: String) -> String? {
        guard let globalKey = alias[aliasKey] else {
            return nil
        }
        return hex[globalKey]
    }

    func getAlpha(_ aliasKey: String) -> Double? {
        return alpha[aliasKey]
    }
}

public struct RCVSampleThemes{
    public var themeName: String
    public var themeType: RCVThemeType
    public var themeDefault: RCVColorPalette
    public var highContrast: RCVColorPalette
    public var priority: Int
    
    init(dictionary: [String: Any]){
        themeName = (dictionary["name"] as? String) ?? ""
        themeType = RCVThemeType(rawValue: dictionary["type"] as? Int ?? 0) ?? .light
        themeDefault = RCVColorPalette(dictionary: dictionary["default"] as? [String: Any] ?? [:])
        highContrast = RCVColorPalette(dictionary: dictionary["highContrast"] as? [String: Any] ?? [:])
        priority = (dictionary["priority"] as? Int) ?? 0
    }
}
