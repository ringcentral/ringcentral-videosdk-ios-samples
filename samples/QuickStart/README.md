# RingCentral Video Client SDK For iOS

## Overview

This sample enables you to quickly get started in your development efforts to create an iOS application with real-time audio/video communication using the RingCentral Video client SDK.

With this sample app you can:

- Join or start a meeting with a valid access token.
- Join after host and waiting room flow.
- Start audio/video communication with participants.
- Mute and unmute local audio.
- Start and stop the local video.
- Mobile phone speaker switch
- Preview meeting information
- Leave or end meeting
- Meeting gallery: Show the participants in the meeting
- Participants action  
&emsp; Preview participants list(In meeting, Not connect, In waiting room)  
&emsp; Invite others by copy meeting link  
&emsp; Mute all audio(allow unmute/block unmute)  
&emsp; Unmute all audio  
&emsp; Mute all video(allow unmute/block unmute)  
&emsp; Unmute all video  
&emsp; Mute/Unmute selected participant's audio/video  
&emsp; Make moderator  
&emsp; Move selected partitipant to waiting room  
&emsp; Remove selected participant from meeting


## Prerequisites

- Xcode 13+
- Physical iPhone or iPad device. Simulators are also supported, however, a real device is recommended because of the performance consideration.
    - OS version 10.0+
- RingCentral Developer Account (free - https://app.ringcentral.com/signup)
- Access to RingCentral Video Documentation (https://ringcentral-ringcentral-video-api-docs.readthedocs-hosted.com/en/latest/ using password "workasone")

## Getting Start

The following steps show you how to prepare, build, and run the sample application.

1. First you will need to install CocoaPods on your machine.
   [CocoaPods install Guide](https://cocoapods.org)

2. Once installed, go to the directory `samples/QuickStart`, run command
   `pod install`
   
3. Open **QuickStart.xcworkspace** in **Xcode**

4. Change the **Enable Bitcode** setting value to **No** under **Build Settings**.

5. If use Simulator in arm64(M1 M2 etc) cpu macbook, Add the **Excluded Architectures** -> **Debug/Release** -> **Any iOS Simulator SDK**  setting value to **arm64** under **Build Settings**

6. If you already have the client ID and client secret, locate the file **AppConfig.swift** in the sample app and replace **{your client id}** and **{your client secret}** with your client ID and secret which got from the RingCentral developer website.

  ```swift
    // Replace your client ID and client secret here
    let ClientID: String = "{your client id}"
    let ClientSecret: String = "{your client secret}"
  ```

7. RingCentral uses auth tokens to authenticate users joining/starting a meeting which makes the communication secure. Follow the steps in our RingCentral Video client SDK Dev Guide (https://ringcentral-ringcentral-video-api-docs.readthedocs-hosted.com/en/latest/sdk/ringcentral-app-auth/) to procure the auth tokens and place the same inside of **AppConfig.swift** file.

  ```swift
    // Place your personal JWT or username and password
    let options = RcvOauthOptions.create()
    
    // Either the JWT flow
    options?.setGrantType(RcvGrantType.jwt)
    options?.setJwt(PersonalJwt)
    // Or the password flow
    options?.setGrantType(RcvGrantType.password)
    options?.setUserName(UserName)
    options?.setPassword(Password)
    
    RcvEngine.instance().authorize(options)
    
    // Replace your token pair string here for testing
    let TokenJsonStr = #"""
    {
        "access_token": "{access token}",
        "token_type": "bearer",
        "expires_in": 3600,
        "refresh_token": "{refresh token}",
        "refresh_token_expires_in": 604800,
        "scope": "Meetings",
        "owner_id": "{owner id}",
        "endpoint_id": "{endpoint id}"
    }
    """#
  ```

### The video client SDK integration

The client SDK framework must be integrated into the sample project before it can be opened and built. Currently, the **rcvsdk.xcframework** has been configured on the sample projects, therefore, you don't need to change it.

### Run the Application

1. Open Xcode and open a project by clicking **File > Open**, select a sample project under the **samples** folder, and click Open.

2. In the project settings, ensure your Apple Developer **Team** is updated to your own under **Signing & Capabilities** and also update the **bundle identifier** to your own.

3. Build and Run the project, if successful, the application should startup in your apple device.

## Contact Us

- Dev Support & Feedback: For feedback, questions or suggestions around SDK please email videosdkfeedback@ringcentral.com or rcv-partners@ringcentral.com
