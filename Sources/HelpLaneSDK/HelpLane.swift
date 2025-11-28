import UIKit

/// Main entry point for the HelpLane SDK
public final class HelpLane {

    // MARK: - Singleton

    public static let shared = HelpLane()

    // MARK: - Configuration

    private var brandToken: String?
    private var baseUrl: String = "https://api.helplane.io"
    private var user: HelpLaneUser?

    private init() {}

    // MARK: - Public API

    /// Configure the SDK with your brand token
    /// - Parameters:
    ///   - brandToken: Your HelpLane brand token
    ///   - baseUrl: Optional custom API base URL (defaults to https://api.helplane.io)
    public static func configure(brandToken: String, baseUrl: String? = nil) {
        shared.brandToken = brandToken
        if let baseUrl = baseUrl {
            shared.baseUrl = baseUrl
        }
    }

    /// Identify the current user
    /// - Parameter user: User information for the chat session
    public static func identify(user: HelpLaneUser) {
        shared.user = user
    }

    /// Clear the current user (for logout)
    public static func clearUser() {
        shared.user = nil
    }

    /// Show the chat widget
    /// - Parameter from: The view controller to present from
    public static func show(from viewController: UIViewController) {
        guard let brandToken = shared.brandToken else {
            print("[HelpLane] Error: SDK not configured. Call HelpLane.configure(brandToken:) first.")
            return
        }

        let chatVC = HelpLaneChatViewController(
            brandToken: brandToken,
            baseUrl: shared.baseUrl,
            user: shared.user
        )

        let navController = UINavigationController(rootViewController: chatVC)
        navController.modalPresentationStyle = .fullScreen
        viewController.present(navController, animated: true)
    }

    /// Show the chat widget in a custom presentation style
    /// - Parameters:
    ///   - from: The view controller to present from
    ///   - style: The modal presentation style
    public static func show(from viewController: UIViewController, style: UIModalPresentationStyle) {
        guard let brandToken = shared.brandToken else {
            print("[HelpLane] Error: SDK not configured. Call HelpLane.configure(brandToken:) first.")
            return
        }

        let chatVC = HelpLaneChatViewController(
            brandToken: brandToken,
            baseUrl: shared.baseUrl,
            user: shared.user
        )

        let navController = UINavigationController(rootViewController: chatVC)
        navController.modalPresentationStyle = style
        viewController.present(navController, animated: true)
    }

    // MARK: - Internal Getters

    internal var currentBrandToken: String? { brandToken }
    internal var currentBaseUrl: String { baseUrl }
    internal var currentUser: HelpLaneUser? { user }
}
