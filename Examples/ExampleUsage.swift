// Example: How to integrate SupportKit in your iOS app
// This file is for reference only - not part of the SDK

import SwiftUI
import SupportKit

// MARK: - Basic Integration (3 lines)

/*
 In your AppDelegate or App init:

 SupportKit.configure(apiKey: "sk_live_your_api_key")

 Then present chat from any view controller:

 SupportKit.presentChat(from: self)
*/

// MARK: - SwiftUI App Example

@main
struct ExampleApp: App {
    init() {
        // Configure SupportKit on launch
        SupportKit.configure(apiKey: "sk_live_your_api_key")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showingChat = false

    var body: some View {
        VStack(spacing: 20) {
            Text("My App")
                .font(.largeTitle)

            Button("Get Help") {
                showingChat = true
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $showingChat) {
            SupportKit.chatView()
        }
    }
}

// MARK: - UIKit Integration Example

/*
 class SettingsViewController: UIViewController {

     @IBAction func helpButtonTapped(_ sender: Any) {
         SupportKit.presentChat(from: self)
     }
 }
*/

// MARK: - Advanced Configuration

struct AdvancedExample {
    static func configureWithOptions() {
        let config = Configuration(
            apiKey: "sk_live_your_api_key",
            theme: Theme(
                primaryColor: "#FF6B00",
                backgroundColor: "#FFFFFF",
                userBubbleColor: "#FF6B00",
                assistantBubbleColor: "#F0F0F0",
                fontName: "Avenir"
            ),
            preferOnDevice: true,
            escalation: EscalationConfig(
                method: .email(address: "support@yourapp.com"),
                promptText: "Would you like to email our team?"
            )
        )

        SupportKit.configure(config)
    }
}

// MARK: - Floating Action Button Example

struct FloatingHelpButton: View {
    @State private var showingChat = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Your main content here
            Color.clear

            // Floating help button
            Button {
                showingChat = true
            } label: {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.white, .blue)
                    .shadow(radius: 4)
            }
            .padding()
        }
        .sheet(isPresented: $showingChat) {
            SupportKit.chatView()
        }
    }
}
