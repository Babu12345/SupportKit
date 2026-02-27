# SupportKit

A Swift package for adding AI-powered customer support to your iOS apps.

## Requirements

- iOS 17.0+
- macOS 14.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add SupportKit to your project using Xcode:

1. Go to **File > Add Package Dependencies**
2. Enter the repository URL:
   ```
   https://github.com/Babu12345/SupportKit
   ```
3. Select the version and click **Add Package**

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Babu12345/SupportKit", from: "1.0.0")
]
```

## Quick Start

### 1. Configure SupportKit

```swift
import SupportKit

// In your App init or AppDelegate
SupportKit.configure(apiKey: "YOUR_API_KEY")
```

### 2. Present the Chat View

**SwiftUI:**
```swift
import SupportKit

struct ContentView: View {
    @State private var showChat = false

    var body: some View {
        Button("Get Help") {
            showChat = true
        }
        .sheet(isPresented: $showChat) {
            SupportKit.chatView()
        }
    }
}
```

**UIKit:**
```swift
import SupportKit

class ViewController: UIViewController {
    @IBAction func helpTapped(_ sender: Any) {
        SupportKit.presentChat(from: self)
    }
}
```

## Features

- AI-powered responses using your knowledge base
- On-device processing for faster responses
- Beautiful, customizable chat UI
- Dark mode support
- Offline caching

## Getting Your API Key

1. Sign up at [appsupportsdk.com](https://www.appsupportsdk.com)
2. Create an organization
3. Copy your API key from the Settings page

## License

Proprietary - All rights reserved
