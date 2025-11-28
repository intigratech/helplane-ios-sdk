import Foundation

/// Push notification manager for HelpLane SDK
///
/// HelpLane uses OneSignal for push notifications. This class provides helpers
/// for integrating OneSignal with HelpLane contacts.
///
/// ## Setup
/// 1. Add OneSignal SDK to your app
/// 2. Initialize OneSignal in your AppDelegate
/// 3. After chat session starts, call `HelpLanePush.login(contactUUID:)`
///
/// ## Example
/// ```swift
/// // In AppDelegate
/// OneSignal.initialize("YOUR_ONESIGNAL_APP_ID")
///
/// // After chat session (you'll get contactUUID from the WebSocket)
/// HelpLanePush.login(contactUUID: "contact-uuid-from-session")
///
/// // On logout
/// HelpLanePush.logout()
/// ```
public final class HelpLanePush {

    // MARK: - Singleton

    public static let shared = HelpLanePush()

    // MARK: - Properties

    private var contactUUID: String?

    private init() {}

    // MARK: - Public API

    /// Login to OneSignal with the contact UUID
    /// Call this after a chat session is established to receive push notifications
    ///
    /// This sets the OneSignal external_id to "contact_{uuid}" which allows
    /// the HelpLane backend to send targeted notifications.
    ///
    /// - Parameter contactUUID: The contact's UUID from HelpLane
    public static func login(contactUUID: String) {
        shared.contactUUID = contactUUID

        // Set external user ID in OneSignal
        // Note: You need to have OneSignal SDK installed and call this:
        // OneSignal.login("contact_\(contactUUID)")
        NotificationCenter.default.post(
            name: NSNotification.Name("HelpLanePushLogin"),
            object: nil,
            userInfo: ["externalId": "contact_\(contactUUID)"]
        )

        print("[HelpLane] Push: Login with external ID: contact_\(contactUUID)")
        print("[HelpLane] Push: Call OneSignal.login(\"contact_\(contactUUID)\") in your app")
    }

    /// Logout from OneSignal
    /// Call this when the user logs out to stop receiving push notifications
    public static func logout() {
        shared.contactUUID = nil

        // Logout from OneSignal
        // Note: You need to have OneSignal SDK installed and call this:
        // OneSignal.logout()
        NotificationCenter.default.post(
            name: NSNotification.Name("HelpLanePushLogout"),
            object: nil
        )

        print("[HelpLane] Push: Logged out")
        print("[HelpLane] Push: Call OneSignal.logout() in your app")
    }

    /// Get the OneSignal external ID for the current contact
    /// Use this to call OneSignal.login() in your app
    ///
    /// - Returns: The external ID string, or nil if not logged in
    public static func getExternalId() -> String? {
        guard let uuid = shared.contactUUID else { return nil }
        return "contact_\(uuid)"
    }

    /// Check if a push notification is from HelpLane
    ///
    /// - Parameter userInfo: The notification payload
    /// - Returns: True if this is a HelpLane notification
    public static func isHelpLaneNotification(_ userInfo: [AnyHashable: Any]) -> Bool {
        if let helplane = userInfo["helplane"] as? String, helplane == "true" {
            return true
        }
        if userInfo["type"] as? String == "new_message" {
            return true
        }
        return false
    }

    /// Get the conversation ID from a HelpLane notification
    ///
    /// - Parameter userInfo: The notification payload
    /// - Returns: The conversation ID, or nil if not present
    public static func getConversationId(_ userInfo: [AnyHashable: Any]) -> String? {
        return userInfo["conversation_id"] as? String
    }

    /// Get the message ID from a HelpLane notification
    ///
    /// - Parameter userInfo: The notification payload
    /// - Returns: The message ID, or nil if not present
    public static func getMessageId(_ userInfo: [AnyHashable: Any]) -> String? {
        return userInfo["message_id"] as? String
    }
}
