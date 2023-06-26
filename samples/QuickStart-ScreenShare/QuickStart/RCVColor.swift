//
//  RCVColor.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

public struct RCVColor {
    public enum ColorType: String {
        case avatarAsh = "$color-avatar-ash"
        case avatarBlueberry = "$color-avatar-blueberry"
        case avatarBrass = "$color-avatar-brass"
        case avatarGlobal = "$color-avatar-global"
        case avatarGold = "$color-avatar-gold"
        case avatarLake = "$color-avatar-lake"
        case avatarOasis = "$color-avatar-oasis"
        case avatarPear = "$color-avatar-pear"
        case avatarPersimmon = "$color-avatar-persimmon"
        case avatarSage = "$color-avatar-sage"
        case avatarTomato = "$color-avatar-tomato"
        case contentBrand = "$color-content-brand"
        case dangerB01 = "$color-danger-b01"
        case dangerB02 = "$color-danger-b02"
        case dangerB03 = "$color-danger-b03"
        case dangerF01 = "$color-danger-f01"
        case dangerF02 = "$color-danger-f02"
        case dangerF11 = "$color-danger-f11"
        case disabledB01 = "$color-disabled-b01"
        case disabledF01 = "$color-disabled-f01"
        case disabledF02 = "$color-disabled-f02"
        case headerB01 = "$color-header-b01"
        case headerBg = "$color-header-bg"
        case headerF01 = "$color-header-f01"
        case headerIcon = "$color-header-icon"
        case headerSearchBox = "$color-header-searchBox"
        case headerStatusbar = "$color-header-statusbar"
        case headerText = "$color-header-text"
        case highlightB01 = "$color-highlight-b01"
        case highlightB02 = "$color-highlight-b02"
        case highlightF01 = "$color-highlight-f01"
        case informativeB01 = "$color-informative-b01"
        case informativeB02 = "$color-informative-b02"
        case informativeF02 = "$color-informative-f02"
        case interactiveB01 = "$color-interactive-b01"
        case interactiveB02 = "$color-interactive-b02"
        case interactiveF01 = "$color-interactive-f01"
        case labelBlack02 = "$color-label-black02"
        case labelBlue02 = "$color-label-blue02"
        case labelGreen01 = "$color-label-green01"
        case labelGreen02 = "$color-label-green02"
        case labelOrange01 = "$color-label-orange01"
        case labelOrange02 = "$color-label-orange02"
        case labelPurple02 = "$color-label-purple02"
        case labelRed01 = "$color-label-red01"
        case labelRed02 = "$color-label-red02"
        case labelTeal02 = "$color-label-teal02"
        case labelYellow02 = "$color-label-yellow02"
        case navIconDefaultMa = "$color-nav-iconDefaultMa"
        case navIconDefault = "$color-nav-iconDefault"
        case navIconSelected = "$color-nav-iconSelected"
        case neutralB01 = "$color-neutral-b01"
        case neutralB02 = "$color-neutral-b02"
        case neutralB03 = "$color-neutral-b03"
        case neutralB04 = "$color-neutral-b04"
        case neutralB05 = "$color-neutral-b05"
        case neutralB06 = "$color-neutral-b06"
        case neutralElevation = "$color-neutral-elevation"
        case neutralF01 = "$color-neutral-f01"
        case neutralF03 = "$color-neutral-f03"
        case neutralF05 = "$color-neutral-f05"
        case neutralF06 = "$color-neutral-f06"
        case neutralF07 = "$color-neutral-f07"
        case neutralL02 = "$color-neutral-l02"
        case presenceAvailable = "$color-presence-available"
        case presenceBusy = "$color-presence-busy"
        case presenceInvisible = "$color-presence-invisible"
        case subAction = "$color-subAction"
        case successB01 = "$color-success-b01"
        case successB02 = "$color-success-b02"
        case successB03 = "$color-success-b03"
        case successF01 = "$color-success-f01"
        case successF02 = "$color-success-f02"
        case successF11 = "$color-success-f11"
        case tabDefault = "$color-tab-default"
        case tabSelected = "$color-tab-selected"
        case umiBg = "$color-umi-bg"
        case umiMentioned = "$color-umi-mentioned"
        case umiText = "$color-umi-text"
        case umiteamBg = "$color-umiteam-bg"
        case umiteamText = "$color-umiteam-text"
        case umiteamMentioned = "$color-umiteam-mentioned"
        case vNeutralB01 = "$color-vNeutral-b01"
        case vNeutralB02 = "$color-vNeutral-b02"
        case video01 = "$color-video01"
        case video02 = "$color-video02"
        case video03 = "$color-video03"
        case video04 = "$color-video04"
        case video05 = "$color-video05"
        case video06 = "$color-video06"
        case video07 = "$color-video07"
        case warningB01 = "$color-warning-b01"
        case warningB02 = "$color-warning-b02"
        case warningB03 = "$color-warning-b03"
        case warningF01 = "$color-warning-f01"
        case warningF02 = "$color-warning-f02"
        case warningF11 = "$color-warning-f11"

        // surviveModeColor is only updated by script
        var surviveModeColor: UIColor {
            switch self {
            case .avatarAsh:
                return UIColor(hex: "#666666")
            case .avatarBlueberry:
                return UIColor(hex: "#5A5ABF")
            case .avatarBrass:
                return UIColor(hex: "#8E6B2B")
            case .avatarGlobal:
                return UIColor(hex: "#509AC4")
            case .avatarGold:
                return UIColor(hex: "#7A7000")
            case .avatarLake:
                return UIColor(hex: "#1A70C1")
            case .avatarOasis:
                return UIColor(hex: "#04549F")
            case .avatarPear:
                return UIColor(hex: "#3C7E44")
            case .avatarPersimmon:
                return UIColor(hex: "#A14B00")
            case .avatarSage:
                return UIColor(hex: "#047C68")
            case .avatarTomato:
                return UIColor(hex: "#C93637")
            case .contentBrand:
                return UIColor(hex: "#066FAC")
            case .dangerB01:
                return UIColor(hex: "#FFF7F5")
            case .dangerB02:
                return UIColor(hex: "#FFE5E0")
            case .dangerB03:
                return UIColor(hex: "#D63E39")
            case .dangerF01:
                return UIColor(hex: "#BE3933")
            case .dangerF02:
                return UIColor(hex: "#BE3933")
            case .dangerF11:
                return UIColor(hex: "#F88878")
            case .disabledB01:
                return UIColor(hex: "#E5E5E5")
            case .disabledF01:
                return UIColor(hex: "#939393")
            case .disabledF02:
                return UIColor(hex: "#C7C7C7")
            case .headerB01:
                return UIColor(hex: "#FFFFFF")
            case .headerBg:
                return UIColor(hex: "#066FAC")
            case .headerF01:
                return UIColor(hex: "#2F2F2F")
            case .headerIcon:
                return UIColor(hex: "#FFFFFF")
            case .headerSearchBox:
                return UIColor(hex: "#FFFFFF")
            case .headerStatusbar:
                return UIColor(hex: "#2F2F2F")
            case .headerText:
                return UIColor(hex: "#FFFFFF")
            case .highlightB01:
                return UIColor(hex: "#FFE6CE")
            case .highlightB02:
                return UIColor(hex: "#FFE5AA")
            case .highlightF01:
                return UIColor(hex: "#2F2F2F")
            case .informativeB01:
                return UIColor(hex: "#F6F9FC")
            case .informativeB02:
                return UIColor(hex: "#E3EBF4")
            case .informativeF02:
                return UIColor(hex: "#066FAC")
            case .interactiveB01:
                return UIColor(hex: "#E6F2F8")
            case .interactiveB02:
                return UIColor(hex: "#066FAC")
            case .interactiveF01:
                return UIColor(hex: "#066FAC")
            case .labelBlack02:
                return UIColor(hex: "#2F2F2F")
            case .labelBlue02:
                return UIColor(hex: "#066FAC")
            case .labelGreen01:
                return UIColor(hex: "#3C9949")
            case .labelGreen02:
                return UIColor(hex: "#32773B")
            case .labelOrange01:
                return UIColor(hex: "#FF8800")
            case .labelOrange02:
                return UIColor(hex: "#A15600")
            case .labelPurple02:
                return UIColor(hex: "#6C5DAF")
            case .labelRed01:
                return UIColor(hex: "#DD6057")
            case .labelRed02:
                return UIColor(hex: "#BE3933")
            case .labelTeal02:
                return UIColor(hex: "#2B727F")
            case .labelYellow02:
                return UIColor(hex: "#896219")
            case .navIconDefault:
                return UIColor(hex: "#2F2F2F")
            case .navIconDefaultMa:
                return UIColor(hex: "#666666")
            case .navIconSelected:
                return UIColor(hex: "#066FAC")
            case .neutralB01:
                return UIColor(hex: "#FFFFFF")
            case .neutralB02:
                return UIColor(hex: "#F9F9F9")
            case .neutralB03:
                return UIColor(hex: "#E5E5E5")
            case .neutralB04:
                return UIColor(hex: "#666666")
            case .neutralB05:
                return UIColor(hex: "#2F2F2F")
            case .neutralB06:
                return UIColor(hex: "#000000")
            case .neutralElevation:
                return UIColor(hex: "#FFFFFF")
            case .neutralF01:
                return UIColor(hex: "#FFFFFF")
            case .neutralF03:
                return UIColor(hex: "#C7C7C7")
            case .neutralF05:
                return UIColor(hex: "#666666")
            case .neutralF06:
                return UIColor(hex: "#2F2F2F")
            case .neutralF07:
                return UIColor(hex: "#FFFFFF")
            case .neutralL02:
                return UIColor(hex: "#E5E5E5")
            case .presenceAvailable:
                return UIColor(hex: "#368541")
            case .presenceBusy:
                return UIColor(hex: "#D63E39")
            case .presenceInvisible:
                return UIColor(hex: "#757575")
            case .subAction:
                return UIColor(hex: "#066FAC")
            case .successB01:
                return UIColor(hex: "#F0FCEF")
            case .successB02:
                return UIColor(hex: "#CEF4CE")
            case .successB03:
                return UIColor(hex: "#368541")
            case .successF01:
                return UIColor(hex: "#32773B")
            case .successF02:
                return UIColor(hex: "#32773B")
            case .successF11:
                return UIColor(hex: "#46BE59")
            case .tabDefault:
                return UIColor(hex: "#666666")
            case .tabSelected:
                return UIColor(hex: "#066FAC")
            case .umiBg:
                return UIColor(hex: "#066FAC")
            case .umiMentioned:
                return UIColor(hex: "#A15600")
            case .umiText:
                return UIColor(hex: "#FFFFFF")
            case .umiteamBg:
                return UIColor(hex: "#666666")
            case .umiteamText:
                return UIColor(hex: "#FFFFFF")
            case .umiteamMentioned:
                return UIColor(hex: "#666666")
            case .vNeutralB01:
                return UIColor(hex: "#000000")
            case .vNeutralB02:
                return UIColor(hex: "#F3F3F3")
            case .video01:
                return UIColor(hex: "#09BBFD")
            case .video02:
                return UIColor(hex: "#066FAC")
            case .video03:
                return UIColor(hex: "#A15600")
            case .video04:
                return UIColor(hex: "#32773B")
            case .video05:
                return UIColor(hex: "#2F2F2F")
            case .video06:
                return UIColor(hex: "#666666")
            case .video07:
                return UIColor(hex: "#FFFFFF")
            case .warningB01:
                return UIColor(hex: "#FFF7F0")
            case .warningB02:
                return UIColor(hex: "#FFE6CE")
            case .warningB03:
                return UIColor(hex: "#B26110")
            case .warningF01:
                return UIColor(hex: "#A15600")
            case .warningF02:
                return UIColor(hex: "#A15600")
            case .warningF11:
                return UIColor(hex: "#FF8800")
            }
        }

        // script update part end
    }
    
    public static func get(_ type: ColorType) -> UIColor {
        guard let color = RCVThemesManager.shared.getColor(key: type.rawValue) else {
            return UIColor().withAlphaComponent(0.6)
        }
            
        return color
    }
    
    public static func image(named name: String) -> UIImage? {
        if name.isEmpty {
            return nil
        }
        let img = UIImage(named: name)
        if img == nil {
            let msg = "Can't find image \(name)"
            assertionFailure(msg)
        }
    
        return img
    }
    
    public static func uiImageByColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 4, height: 4)

        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale)
        
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(rect)
        
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return theImage!.resizableImage(withCapInsets: UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
    }
}
