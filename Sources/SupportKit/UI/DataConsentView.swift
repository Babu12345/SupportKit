import SwiftUI

// MARK: - Consent Manager

enum DataConsentManager {
    private static let consentKey = "supportkit_data_sharing_consent"

    static var hasConsented: Bool {
        UserDefaults.standard.bool(forKey: consentKey)
    }

    static func setConsented() {
        UserDefaults.standard.set(true, forKey: consentKey)
    }

    static func revokeConsent() {
        UserDefaults.standard.removeObject(forKey: consentKey)
    }
}

// MARK: - Consent View

@available(iOS 17.0, macOS 14.0, *)
struct DataConsentView: View {
    let onAgree: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 50))
                            .foregroundStyle(Color.accentColor)

                        Text("Data Sharing Consent")
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Your privacy matters to us")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top)

                    Divider()

                    // What data is shared
                    VStack(alignment: .leading, spacing: 12) {
                        Label("What Data Will Be Shared", systemImage: "doc.text")
                            .font(.headline)
                            .foregroundStyle(Color.accentColor)

                        Text("When you use support chat, the following information is sent to our AI provider:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 8) {
                            DataItem(icon: "text.bubble", text: "Your support questions and messages")
                            DataItem(icon: "clock.arrow.circlepath", text: "Conversation history during the session")
                        }
                        .padding(.leading, 8)
                    }

                    // What is NOT shared
                    VStack(alignment: .leading, spacing: 12) {
                        Label("What Is NOT Shared", systemImage: "lock.shield")
                            .font(.headline)
                            .foregroundStyle(.green)

                        VStack(alignment: .leading, spacing: 8) {
                            DataItem(icon: "person.slash", text: "Personal account details", color: .green)
                            DataItem(icon: "iphone.slash", text: "Device information", color: .green)
                            DataItem(icon: "chart.bar.xaxis", text: "App usage data", color: .green)
                        }
                        .padding(.leading, 8)
                    }

                    // Who receives the data
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Who Receives Your Data", systemImage: "building.2")
                            .font(.headline)
                            .foregroundStyle(Color.accentColor)

                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "cpu")
                                .font(.title2)
                                .foregroundStyle(Color.accentColor)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("SupportKit AI")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)

                                Text("SupportKit AI uses advanced language models to understand your questions and provide accurate, helpful support responses.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Link(destination: URL(string: "https://www.appsupportsdk.com/privacy")!) {
                                    HStack(spacing: 4) {
                                        Text("View SupportKit Privacy Policy")
                                        Image(systemName: "arrow.up.right")
                                    }
                                    .font(.caption)
                                }
                                .padding(.top, 4)
                            }
                        }
                        .padding()
                        #if canImport(UIKit)
                        .background(Color(.secondarySystemBackground))
                        #else
                        .background(Color.gray.opacity(0.1))
                        #endif
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // How data is used
                    VStack(alignment: .leading, spacing: 12) {
                        Label("How Your Data Is Used", systemImage: "gearshape.2")
                            .font(.headline)
                            .foregroundStyle(Color.accentColor)

                        VStack(alignment: .leading, spacing: 8) {
                            BulletPoint(text: "Your data is used solely to generate support responses")
                            BulletPoint(text: "Conversation data is not stored permanently on our servers")
                            BulletPoint(text: "Data is transmitted securely using encryption (HTTPS/TLS)")
                            BulletPoint(text: "AI providers process your data according to our privacy policy")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 12) {
                    Button {
                        onAgree()
                    } label: {
                        Text("I Agree")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.borderedProminent)

                    Button {
                        onCancel()
                    } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(.ultraThinMaterial)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        onCancel()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .interactiveDismissDisabled()
    }
}

// MARK: - Helper Views

private struct DataItem: View {
    let icon: String
    let text: String
    var color: Color = .primary

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color.opacity(0.8))
                .frame(width: 20)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(color == .primary ? .primary : color)
        }
    }
}

private struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

@available(iOS 17.0, macOS 14.0, *)
#Preview {
    DataConsentView(
        onAgree: {},
        onCancel: {}
    )
}
