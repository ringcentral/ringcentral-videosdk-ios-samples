//
//  RCVIconUtils.swift
//  RcvSwiftSampleMeeting
//
//  Created by Simon Xiang on 1/11/23.
//

import UIKit
import rcvsdk

public class RCVIconUtils {
    public static let shared = RCVIconUtils()
    
    lazy var rcTomato: UIImage = UIImage(color: RCVColor.get(.avatarTomato))!
    lazy var rcBlueberry: UIImage = UIImage(color: RCVColor.get(.avatarBlueberry))!
    lazy var rcOasis: UIImage = UIImage(color: RCVColor.get(.avatarOasis))!
    lazy var rcGold: UIImage = UIImage(color: RCVColor.get(.avatarGold))!
    lazy var rcSage: UIImage = UIImage(color: RCVColor.get(.avatarSage))!
    lazy var rcAsh: UIImage = UIImage(color: RCVColor.get(.avatarAsh))!
    lazy var rcPersimmon: UIImage = UIImage(color: RCVColor.get(.avatarPersimmon))!
    lazy var rcPear: UIImage = UIImage(color: RCVColor.get(.avatarPear))!
    lazy var rcBrass: UIImage = UIImage(color: RCVColor.get(.avatarBrass))!
    lazy var rcLake: UIImage = UIImage(color: RCVColor.get(.avatarLake))!
    
    lazy var rcTomatoOnNavigation: UIImage = UIImage(color: RCVColor.get(.avatarTomato), size: CGSize(width: 40, height: 40))!
    lazy var rcBlueberryOnNavigation: UIImage = UIImage(color: RCVColor.get(.avatarBlueberry), size: CGSize(width: 40, height: 40))!
    lazy var rcOasisOnNavigation: UIImage = UIImage(color: RCVColor.get(.avatarOasis), size: CGSize(width: 40, height: 40))!
    lazy var rcGoldOnNavigation: UIImage = UIImage(color: RCVColor.get(.avatarGold), size: CGSize(width: 40, height: 40))!
    lazy var rcSageOnNavigation: UIImage = UIImage(color: RCVColor.get(.avatarSage), size: CGSize(width: 40, height: 40))!
    lazy var rcAshOnNavigation: UIImage = UIImage(color: RCVColor.get(.avatarAsh), size: CGSize(width: 40, height: 40))!
    lazy var rcPersimmonOnNavigation: UIImage = UIImage(color: RCVColor.get(.avatarPersimmon), size: CGSize(width: 40, height: 40))!
    lazy var rcPearOnNavigation: UIImage = UIImage(color: RCVColor.get(.avatarPear), size: CGSize(width: 40, height: 40))!
    lazy var rcBrassOnNavigation: UIImage = UIImage(color: RCVColor.get(.avatarBrass), size: CGSize(width: 40, height: 40))!
    lazy var rcLakeOnNavigation: UIImage = UIImage(color: RCVColor.get(.avatarLake), size: CGSize(width: 40, height: 40))!
}
