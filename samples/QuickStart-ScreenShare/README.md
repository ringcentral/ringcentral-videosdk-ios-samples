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

3. Open the AppDelegate.swift file in the "QuickStart" project and locate the line `RcvEngine.instance().setAppGroupName("group.com.ringcentral.rcv.sample")`. Replace the string `"group.com.ringcentral.rcv.sample"` with your own App Group ID obtained in step 2.

4. Open the SampleHandler.swift file in the "QuickStartBroadcast" target and find the following code snippet:
   ```
   private var appGroupName: String {
        // Note: replace with Your App Group Identifier.
        return "group.com.ringcentral.rcv.sample"
   }
   ```
   Replace `"group.com.ringcentral.rcv.sample"` with your own App Group ID obtained in step 2.

5. If you have modified the App ID of the "QuickStartBroadcast" target, update the line `broadcastPicker.preferredExtension = "com.ringcentral.video.quickstart.QuickStartBroadcast"` accordingly.

6. Build and run the app to test the setup.

## Frequently Questions
7. Why does iOS stop capturing when screen sharing is activated and the app enters the background?

Enable audio recording in the background mode for the application.