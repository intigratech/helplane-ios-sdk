import Foundation

/// User information for HelpLane chat sessions
public struct HelpLaneUser {

    /// External user ID from your system
    public var userId: String?

    /// User's email address
    public var email: String?

    /// User's display name
    public var name: String?

    /// User's phone number
    public var phone: String?

    /// User tier/plan (e.g., "free", "pro", "enterprise")
    public var tier: String?

    /// Custom metadata dictionary
    public var meta: [String: Any]?

    /// Initialize a new HelpLane user
    /// - Parameters:
    ///   - userId: External user ID from your system
    ///   - email: User's email address
    ///   - name: User's display name
    ///   - phone: User's phone number
    ///   - tier: User tier/plan
    ///   - meta: Custom metadata
    public init(
        userId: String? = nil,
        email: String? = nil,
        name: String? = nil,
        phone: String? = nil,
        tier: String? = nil,
        meta: [String: Any]? = nil
    ) {
        self.userId = userId
        self.email = email
        self.name = name
        self.phone = phone
        self.tier = tier
        self.meta = meta
    }
}
