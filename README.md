# HelpLane iOS SDK

Add live chat support to your iOS app with the HelpLane SDK.

## Requirements

- iOS 13.0+
- Swift 5.5+

## Installation

### Swift Package Manager

Add the package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/intigratech/helplane-ios-sdk.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** and enter:
```
https://github.com/intigratech/helplane-ios-sdk.git
```

## Quick Start

### 1. Initialize the SDK

```swift
import HelpLaneSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        HelpLane.configure(brandToken: "your-brand-token")

        return true
    }
}
```

### 2. Identify Users (Optional)

```swift
let user = HelpLaneUser(
    id: "user-123",
    name: "John Doe",
    email: "john@example.com"
)
HelpLane.identify(user: user)
```

### 3. Show the Chat

```swift
// Present as a modal
HelpLane.presentChat(from: viewController)

// Or get the view controller to push onto a navigation stack
let chatVC = HelpLane.chatViewController()
navigationController?.pushViewController(chatVC, animated: true)
```

## Push Notifications

HelpLane uses OneSignal for push notifications. If you're already using OneSignal:

```swift
import HelpLaneSDK

// After OneSignal initialization
HelpLanePush.registerForPushNotifications()

// Handle notification tap
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) {
    if HelpLanePush.handleNotification(response.notification.request.content.userInfo) {
        HelpLane.presentChat(from: topViewController)
    }
}
```

## Configuration Options

```swift
HelpLane.configure(
    brandToken: "your-brand-token",
    baseURL: "https://your-instance.helplane.io"  // Optional: custom instance
)
```

## API Reference

### HelpLane

| Method | Description |
|--------|-------------|
| `configure(brandToken:baseURL:)` | Initialize the SDK |
| `identify(user:)` | Set the current user |
| `clearUser()` | Clear user data |
| `presentChat(from:)` | Present chat modally |
| `chatViewController()` | Get chat view controller |

### HelpLaneUser

| Property | Type | Description |
|----------|------|-------------|
| `id` | String | Unique user identifier |
| `name` | String? | Display name |
| `email` | String? | Email address |
| `avatarURL` | String? | Profile image URL |
| `customAttributes` | [String: Any]? | Custom data |

## Support

- Issues: [GitHub Issues](https://github.com/intigratech/helplane-ios-sdk/issues)

## License

MIT License - see [LICENSE](LICENSE) for details.
