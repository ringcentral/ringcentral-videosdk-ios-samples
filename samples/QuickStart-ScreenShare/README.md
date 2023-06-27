# RingCentral Video Client SDK Screen Share For iOS


## Introduction
Screen sharing refers to the process of sharing screen content with other viewers in the form of video

## Sample

## Prerequisites
Before implementing the screen sharing feature, please ensure the following:

- Use an iOS device or simulator that supports audio and video, with a minimum version of iOS 12.0 (real devices are recommended).

- Due to the high performance requirements of the screen sharing feature, it is recommended to use iPhone X or newer models.

## Implementation Process
Screen sharing on the iOS platform is achieved by utilizing Apple's [ReplayKit](https://developer.apple.com/documentation/ReplayKit) framework, which allows for capturing and sharing the entire screen content of the system. However, it requires an additional Extension component (Extension process) to be provided by the current app (main app process) for screen recording. This is combined with the relevant APIs of RingCentral Video Client SDK to implement the screen sharing feature.

## Usage Steps
### Follow these steps to set up the QuickStart sample:
1. Make sure you have the sample project "QuickStart" available.

2. The "QuickStart" and "QuickStartBroadcast" targets use the same App Group ID. For example, use the group ID "group.com.ringcentral.rcv.sample".
   <img width="887" alt="image" src="https://github.com/ringcentral/ringcentral-videosdk-ios-samples/assets/17132949/c8399dc2-1ec8-4db1-bde6-acce8f31d591">
   <img width="880" alt="image" src="https://github.com/ringcentral/ringcentral-videosdk-ios-samples/assets/17132949/0deeaa8b-166d-4438-977c-d40e4318e411">



3. Open the AppDelegate.swift file in the "QuickStart" project and locate the line `RcvEngine.instance().setAppGroupName("group.com.ringcentral.rcv.sample")`. Replace the string `"group.com.ringcentral.rcv.sample"` with your own App Group ID obtained in step 2.
   <img width="400" alt="image" src="https://github.com/ringcentral/ringcentral-videosdk-ios-samples/assets/17132949/0b7514b3-a49b-4c3c-a96c-9915814d1c32">


4. Open the SampleHandler.swift file in the "QuickStartBroadcast" target and find the following code snippet:
   ```
   private var appGroupName: String {
        // Note: replace with Your App Group Identifier.
        return "group.com.ringcentral.rcv.sample"
   }
   ```
   Replace `"group.com.ringcentral.rcv.sample"` with your own App Group ID obtained in step 2.
   
   <img width="400" alt="image" src="https://github.com/ringcentral/ringcentral-videosdk-ios-samples/assets/17132949/a50011f6-f41e-4571-b1f4-476b6e1ab5cb">


6. If you have modified the App ID of the "QuickStartBroadcast" target, update the line `broadcastPicker.preferredExtension = "com.ringcentral.video.quickstart.QuickStartBroadcast"` in file `ActiveMeetingViewController.swift` accordingly.

7. Build and run the app.

## Frequently Questions
- Why does iOS stop capturing when screen sharing is activated and the app enters the background?

Enable audio recording in the background mode for the application.

<img width="800" alt="image" src="https://github.com/ringcentral/ringcentral-videosdk-ios-samples/assets/17132949/3cddff42-075d-4345-8950-8f6e2ad06b34">
