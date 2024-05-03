# PersonalizationKit Initialization Guide

## Overview
`PersonalizationKit` is designed to streamline the management of learner data, activities, and analytics. Follow these instructions to integrate and initialize the library in your iOS project.

## Prerequisites
Ensure you have `PersonalizationKit` installed in your project. If it's distributed as a pod. Add it to your project repo as a submodule, then add this line to your podfile:

```
pod 'PersonalizationKit', :path => "./PersonalizationKit"
```


## Step-by-step Initialization

### Step 1: Import PersonalizationKit
Start by importing `PersonalizationKit` in your AppDelegate or the initial configuring class as follows:

```swift
import PersonalizationKit
```

### Step 2: Configure Storage

Set the static storage for learner, activity, and analytics components. This storage is used across the application for saving and retrieving data persistently.

```swift
LocalLearner.staticStorage = LocalStorage.shared
ActivityService.staticStorage = LocalStorage.shared
Analytics.initialStaticStorage = LocalStorage.shared
```

### Step 3: Initialize Services
Initialize each service with the necessary configuration. This typically involves kickstarting the services with user-specific data, such as analytics IDs, and pre-defined property keys.

```swift
// Initialize the Local Learner
LocalLearner.shared.kickstartLocalLearner(
    analyticsId: localUser.analyticsId,
    learnerPropertyKeys: LearnerProperties.allCases.map { $0.rawValue }
)

// Start the Activity Service
ActivityService.shared.kickstartActivityService()

// Increment launch count in Analytics
Analytics.shared.incrementLaunchCount()
```

### Step 4: Advanced Configuration
Check for certain conditions to decide whether to synchronize data with a remote server or perform additional initializations:

```swift
if let _ = LocalLearner.shared.getProperty(LearnerProperties.goal.rawValue),
   let localHistory = ActivityService.shared.localActivityHistory,
   localHistory.count > 100,
   localHistory.contains(where: {$0.activityId == "launch" && $0.value == 1 }) {
    // Kickstart remote learner synchronization
    LearnerService.shared.kickstartRemoteLearner()

    // Synchronize activities to a remote server
    ActivityService.shared.syncActivitiesToFS()
}
```

### Conclusion
Following these steps ensures that your application is fully integrated with PersonalizationKit, making use of its functionality to manage learner data, track activities, and analyze user engagement effectively.
