# RingCentral Video Client SDK For iOS

## Overview

This repository contains a sample project using the RingCentral video SDK for iOS. This tutorial guides you to get started in your development efforts to create an iOS app with real-time audio/video communications.

With the video client SDK you can:

- Joins or starts a meeting with a valid authentication token.
- Joins the meeting as a guest. (The app needs to get the authorization of the guest type first)
- Starts the audio/video communication with the meeting users.
- Mutes and unmutes the local audio.
- Starts and stops the local video.
- Sharing the device screen or camera.
- Sends in-meeting private and public chat messages.
- Receives the meeting and media event callbacks, such as participant joined/leave, audio/video muted/unmuted.
- Host or moderator privileges:
    - Mutes and unmutes a specific meeting user's audio or video.
    - Mutes and unmutes all meeting users' audio or video.
    - Locks and unlocks the meeting.
    - Starts and pauses the recording.
    - Assigns and revokes the moderator role with meeting users.
    - Puts in-meeting users into the waiting room.
    - Admits and denies a user from the waiting room.
    - Admits all users from the waiting room.
    - Stops the remote user's sharing.
    - Locks and unlocks the meeting sharing function.
    - Disallows the meeting users to send the chat message.
    - Removes the meeting user from the meeting.

## Prerequisites

- Xcode 13+
- Physical iPhone or iPad device. Simulators are also supported, however, a real device is recommended because of the performance consideration.
    - OS version 13.0+
- RingCentral Developer Account (free - https://app.ringcentral.com/signup)
- Access to RingCentral Video Documentation (https://ringcentral-ringcentral-video-api-docs.readthedocs-hosted.com/en/latest/ using password "workasone")

## How To Run The Sample Projects

The sample project can enable you to quickly get started in the development efforts using the RingCentral Video client SDK. For detailed information, check the README file of each sample project.

## How To Program Real-time Video With iOS

To start using the iOS programmable video client SDK in your applications, you need to perform a few steps as follows. There are two ways for integrating, however, the current video client SDK is provided by the local package, so only supports manually copying the SDK framework right now.

1. First you will need to install CocoaPods on your machine.
   [CocoaPods install Guide](https://cocoapods.org)

2. Once installed, go to the directory `samples/QuickStart`, run command
   `pod install`
   
3. Open **QuickStart.xcworkspace** in **Xcode**

4. Change the **Enable Bitcode** setting value to **No** under **Build Settings**.

5. If use Simulator in arm64(M1 M2 etc) cpu macbook, Add the **Excluded Architectures** -> **Debug/Release** -> **Any iOS Simulator SDK**  setting value to **arm64** under **Build Settings**

6. Use your client ID and client secret to initial the RCV client SDK engine as code below, the client ID and client secret are required.

    ```swift
    RcvEngine.create(<#ClientID#>, appSecret: <#ClientSecret#>)
    ```

7. If you intend to host a meeting or access your extension information, such as the meeting list or the recording list, etc, follow the steps in our RingCentral Video client SDK Dev Guide (https://ringcentral-ringcentral-video-api-docs.readthedocs-hosted.com/en/latest/sdk/ringcentral-app-auth/) to procure the RingCentral authorization tokens and invoke the API method as code below.

    ```swift
    RcvEngine.instance().setAuthToken(<#authorization token string#>, autoRefresh: true)
    ```

8.  Next, follow the dev guide and API documentation or the sample projects to build your video application, enjoy programming!

## Known Issues

- Some interfaces are not supported yet in the current version, they are being actively developed. For example, the breakout room, etc.

## Contact Us

- Dev Support & Feedback: For feedback, questions or suggestions around SDK please email rcv-partners@ringcentral.com or videosdkfeedback@ringcentral.com
