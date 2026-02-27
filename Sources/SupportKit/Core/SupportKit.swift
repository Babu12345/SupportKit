import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Main entry point for SupportKit SDK
@available(iOS 17.0, macOS 14.0, *)
public final class SupportKit {

    /// Shared instance
    public static let shared = SupportKit()

    /// Current configuration
    private(set) var configuration: Configuration?

    /// Chat engine handles message processing
    private var engine: ChatEngine?

    private init() {}

    // MARK: - Public API

    /// Configure SupportKit with your API key
    /// - Parameter apiKey: Your SupportKit API key from the dashboard
    @MainActor
    public static func configure(apiKey: String) {
        configure(Configuration(apiKey: apiKey))
    }

    /// Configure SupportKit with a full configuration object
    /// - Parameter configuration: Configuration options
    @MainActor
    public static func configure(_ configuration: Configuration) {
        shared.configuration = configuration
        shared.engine = ChatEngine(configuration: configuration)
    }

    #if canImport(UIKit)
    /// Present the chat interface modally (iOS/iPadOS)
    /// - Parameter viewController: The view controller to present from
    @MainActor
    public static func presentChat(from viewController: UIViewController) {
        guard shared.configuration != nil, let engine = shared.engine else {
            assertionFailure("SupportKit.configure() must be called before presentChat()")
            return
        }

        let chatView = ChatView(engine: engine)
        let hostingController = UIHostingController(rootView: chatView)
        hostingController.modalPresentationStyle = .pageSheet

        if let sheet = hostingController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        viewController.present(hostingController, animated: true)
    }
    #endif

    /// Dismiss the chat interface
    @MainActor
    public static func dismissChat() {
        // Will be handled by the presenting view controller
    }
}

// MARK: - SwiftUI Integration

@available(iOS 17.0, macOS 14.0, *)
public extension SupportKit {

    /// SwiftUI view for embedding chat directly
    @MainActor
    static func chatView() -> some View {
        guard let engine = shared.engine else {
            fatalError("SupportKit.configure() must be called before using chatView()")
        }
        return ChatView(engine: engine)
    }
}
