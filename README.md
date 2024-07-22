# PersonalizationKit Initialization Guide

## Overview
`PersonalizationKit` is designed to streamline the management of learner data, activities, and analytics. Follow these instructions to integrate and initialize the library in your iOS project.

## Prerequisites

`PersonalizationKit` can be integrated into your project as a pod. 

Add it to your project repo as a submodule: 
```
git submodule add git@github.com:iOSerler/PersonalizationKit.git
```

Then add this line to your podfile:
```
pod 'PersonalizationKit', :path => "./PersonalizationKit"
```
The run `pod install` in the terminal. 

## Step-by-step Initialization

### Step 1: Import PersonalizationKit
Start by importing `PersonalizationKit` in your AppDelegate or the initial configuring class as follows:

```swift
import PersonalizationKit
```

### Step 2: Configure Storage

First, you need to define an instance of the `LearnerStorage` protocol. Any storage can be used, even UserDefaults. Example below implements `LocalStorage`.

```swift
import Foundation
import PersonalizationKit

class LocalStorage: NSObject, LearnerStorage {

    var serverUrl: String =  "https://yourbackend.server"
    var learnerCollectionName: String = "appname_learner"
    var activtyLogCollectionName: String = "activity_log"
    
    static let shared = LocalStorage()
    
    func store(_ anyObject: Any, forKey key: String) {
        UserDefaults.standard.set(anyObject, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func retrieve(forKey key: String) -> Any? {
        if let any = UserDefaults.standard.object(forKey: key) {
            return any
        } else if let any = UserDefaults.standard.object(forKey: key) {
            return any
        } else {
            return nil
        }
    }
    
    func remove(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
        
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getAllItemKeys(withPrefix: String) -> [String] {
        return Array(UserDefaults.standard.dictionaryRepresentation().keys.filter { (key) -> Bool in
                return key.contains(withPrefix)
        } ?? [])
    }
    
    func localizedString(forKey key: String) -> String {
        key.localized()
    }
    
}

```

We then set the static storage for learner, activity, and analytics components. This storage is used across the application for saving and retrieving data persistently.

```swift
LocalLearner.staticStorage = LocalStorage.shared
ActivityService.staticStorage = LocalStorage.shared
LearnerService.staticStorage = LocalStorage.shared
Analytics.staticStorage = LocalStorage.shared
```

### Step 3: Initialize Services
Initialize each service with the necessary configuration. This typically involves kickstarting the services with user-specific data, such as analytics IDs, and pre-defined property keys.

```swift
// Initialize the Local Learner
LocalLearner.shared.kickstartLocalLearner(
    analyticsId: {add_some_persistent_uuid_assigned_to_your_user},
    learnerPropertyKeys: LearnerProperties.allCases.map { $0.rawValue }
)

// Start the Activity Service
ActivityService.shared.kickstartActivityService()

// Increment launch count in Analytics
Analytics.shared.incrementLaunchCount()
```

The learner properties enum needs to be defined by you, as you decide what properties you care about. For example, it can be something like this:
```swift
public enum LearnerProperties: String, CaseIterable {
    case gender
    case language
    
    case learnerType = "learner_type"
    
    case apnsToken = "apnsToken"
    
    case launchCount = "launch_count"// "appOpenedCount"
    case bundleVersionAtInstall = "bundleVersionAtInstall" /// eventually replace with "bundle_version_at_install"
    
    case countryCode = "country_code"
    case city

    case experimentParticipant = "experiment_participant"
}
```

### Step 4: Advanced Configuration
Check for certain conditions to decide whether to synchronize data with a remote server or perform additional initializations:

```swift
if let launchCount = Int(LocalLearner.shared.getProperty(LearnerProperties.launchCount.rawValue)),
   launchCount > 2,
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
