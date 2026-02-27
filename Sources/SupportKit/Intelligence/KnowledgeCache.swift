import Foundation

/// Caches knowledge base content for on-device and offline use
final class KnowledgeCache {

    /// The full knowledge base content
    private(set) var content: String = ""

    /// Bundle metadata
    private(set) var version: String = ""
    private(set) var lastUpdated: Date?

    /// File URL for persisted cache
    private let cacheURL: URL

    init() {
        let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheURL = cacheDir.appendingPathComponent("supportkit_knowledge.json")

        loadFromDisk()

        // Load mock content for development
        #if DEBUG
        if content.isEmpty {
            loadMockContent()
        }
        #endif
    }

    // MARK: - Public API

    /// Update the cache with new content from the server
    func update(with bundle: KnowledgeBundle) {
        self.content = bundle.content
        self.version = bundle.version
        self.lastUpdated = bundle.lastUpdated

        saveToDisk()
    }

    /// Clear the cache
    func clear() {
        content = ""
        version = ""
        lastUpdated = nil

        try? FileManager.default.removeItem(at: cacheURL)
    }

    // MARK: - Persistence

    private func saveToDisk() {
        let bundle = KnowledgeBundle(
            version: version,
            lastUpdated: lastUpdated ?? Date(),
            content: content
        )

        do {
            let data = try JSONEncoder().encode(bundle)
            try data.write(to: cacheURL)
        } catch {
            print("[SupportKit] Failed to save knowledge cache: \(error)")
        }
    }

    private func loadFromDisk() {
        guard FileManager.default.fileExists(atPath: cacheURL.path) else { return }

        do {
            let data = try Data(contentsOf: cacheURL)
            let bundle = try JSONDecoder().decode(KnowledgeBundle.self, from: data)
            self.content = bundle.content
            self.version = bundle.version
            self.lastUpdated = bundle.lastUpdated
        } catch {
            print("[SupportKit] Failed to load knowledge cache: \(error)")
        }
    }

    // MARK: - Mock Content (Development Only)

    #if DEBUG
    private func loadMockContent() {
        content = """
        # Acme App Help Center

        ## Account & Login

        ### How do I reset my password?
        To reset your password:
        1. Go to Settings > Account > Change Password
        2. Enter your current password
        3. Enter your new password twice
        4. Tap "Save"

        If you've forgotten your password, tap "Forgot Password" on the login screen and we'll email you a reset link.

        ### How do I change my email address?
        Go to Settings > Account > Email. Enter your new email address and confirm with your password. We'll send a verification email to your new address.

        ### How do I delete my account?
        We're sorry to see you go! To delete your account:
        1. Go to Settings > Account > Delete Account
        2. Enter your password to confirm
        3. Tap "Delete Forever"

        Note: This action is permanent and cannot be undone. All your data will be deleted within 30 days.

        ## Billing & Subscriptions

        ### How do I upgrade to Pro?
        Go to Settings > Subscription > Upgrade to Pro. You can choose monthly ($9.99/month) or yearly ($99.99/year, save 17%).

        ### How do I cancel my subscription?
        Go to Settings > Subscription > Manage. Tap "Cancel Subscription". You'll keep access until the end of your billing period.

        ### How do I get a refund?
        We offer a 30-day money-back guarantee. Contact us at support@acme.app with your account email and we'll process your refund within 3-5 business days.

        ## Features

        ### How do I enable dark mode?
        Go to Settings > Appearance > Theme and select "Dark". You can also choose "System" to match your device settings.

        ### How do I export my data?
        Go to Settings > Data > Export. Choose your format (JSON or CSV) and tap "Export". We'll email you a download link within 24 hours.

        ### How do I enable notifications?
        Go to Settings > Notifications and toggle on the notifications you want to receive. Make sure you've also enabled notifications for Acme App in your device settings.

        ## Contact

        For issues not covered here, email us at support@acme.app or visit our website at https://acme.app/help
        """

        version = "mock-1.0"
        lastUpdated = Date()
    }
    #endif
}

// MARK: - Knowledge Bundle

struct KnowledgeBundle: Codable {
    let version: String
    let lastUpdated: Date
    let content: String
}
