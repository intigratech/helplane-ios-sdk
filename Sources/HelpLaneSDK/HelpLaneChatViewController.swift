import UIKit
import WebKit

/// View controller that displays the HelpLane chat widget in a WKWebView
public final class HelpLaneChatViewController: UIViewController {

    // MARK: - Properties

    private let brandToken: String
    private let baseUrl: String
    private let user: HelpLaneUser?

    private var webView: WKWebView!
    private var loadingIndicator: UIActivityIndicatorView!

    // MARK: - Initialization

    init(brandToken: String, baseUrl: String, user: HelpLaneUser?) {
        self.brandToken = brandToken
        self.baseUrl = baseUrl
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupWebView()
        loadWidget()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Support"

        // Close button
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        // Loading indicator
        loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        loadingIndicator.startAnimating()
    }

    private func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true

        // Enable localStorage
        config.websiteDataStore = .default()

        // Allow JavaScript
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        config.defaultWebpagePreferences = preferences

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground

        view.insertSubview(webView, at: 0)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadWidget() {
        let html = generateWidgetHTML()
        webView.loadHTMLString(html, baseURL: URL(string: baseUrl))
    }

    private func generateWidgetHTML() -> String {
        var settings: [String: Any] = [
            "brandToken": brandToken,
            "baseUrl": baseUrl,
            "embedded": true  // Tell widget it's in embedded/SDK mode
        ]

        if let user = user {
            if let userId = user.userId {
                settings["userID"] = userId
            }
            if let email = user.email {
                settings["email"] = email
            }
            if let name = user.name {
                settings["name"] = name
            }
            if let phone = user.phone {
                settings["phone"] = phone
            }
            if let tier = user.tier {
                settings["tier"] = tier
            }
            if let meta = user.meta {
                settings["meta"] = meta
            }
        }

        let settingsJSON: String
        if let jsonData = try? JSONSerialization.data(withJSONObject: settings),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            settingsJSON = jsonString
        } else {
            settingsJSON = "{}"
        }

        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                html, body {
                    width: 100%;
                    height: 100%;
                    overflow: hidden;
                    background: transparent;
                }
                /* Override widget positioning for embedded mode */
                #helplane-widget-container {
                    position: fixed !important;
                    top: 0 !important;
                    left: 0 !important;
                    right: 0 !important;
                    bottom: 0 !important;
                    width: 100% !important;
                    height: 100% !important;
                }
                /* Hide the launcher button in embedded mode */
                [data-helplane-launcher] {
                    display: none !important;
                }
            </style>
        </head>
        <body>
            <script>
                window.HelpLaneSettings = \(settingsJSON);
                // Auto-open the widget in embedded mode
                window.HelpLaneSettings.autoOpen = true;
                window.HelpLaneSettings.hideLauncher = true;
            </script>
            <script src="\(baseUrl)/api/widget/client.js" defer></script>
        </body>
        </html>
        """
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension HelpLaneChatViewController: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIndicator.stopAnimating()
    }

    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        showError(error)
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadingIndicator.stopAnimating()
        showError(error)
    }

    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        // Open external links in Safari
        if navigationAction.navigationType == .linkActivated,
           let url = navigationAction.request.url,
           url.host != URL(string: baseUrl)?.host {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Connection Error",
            message: "Unable to load chat. Please check your internet connection and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.loadWidget()
            self?.loadingIndicator.startAnimating()
        })
        alert.addAction(UIAlertAction(title: "Close", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}
