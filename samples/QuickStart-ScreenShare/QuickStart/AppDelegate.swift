//
//  AppDelegate.swift
//  RcvSwiftSample1v1meeting
//
//  Created by Yi Ke on 7/21/22.
//

import UIKit
import rcvsdk

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        RcvEngine.create(ClientID, clientSecret: ClientSecret)
        
        // There are two options to do the authentication.
        
        // (1) Using the JWT or password OAuth flow,
        // the client SDK will take care the authorization process.
        //let options = RcvOauthOptions.create()
        // Using the JWT flow
        //options?.setGrantType(RcvGrantType.jwt)
        //options?.setJwt(PersonalJwt)
        // Or using the password flow
//        options?.setGrantType(RcvGrantType.password)
//        options?.setUserName(UserName)
//        options?.setPassword(Password)
//        RcvEngine.instance().authorize(options)
        
        // (2) You already have the auth token pair, pass it to the SDK as below.
        RcvEngine.instance().setAuthToken(TokenJsonStr, autoRefresh: true)
        
        RcvEngine.instance().setAppGroupName("group.com.ringcentral.rcv.sample")
        
        loadDynamicResources()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        RcvEngine.instance().destroy()
    }
    
    func loadDynamicResources() {
        RCVThemesManager.shared.deployThemesInfo()
    }
    
}

