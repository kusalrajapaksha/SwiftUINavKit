# SwiftUINavKit

A powerful navigation router for SwiftUI that bridges UIKit's `UINavigationController` with SwiftUI, providing programmatic navigation with type-safety and full UIKit customization.

[![Swift Version](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%2015%2B-lightgrey.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![SPM Compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg)](https://swift.org/package-manager/)

## Features

✨ **Programmatic Navigation** - Navigate from anywhere in your app  
🎯 **Type-Safe** - Navigate to specific view types with compile-time safety  
🔗 **Route Identification** - Assign custom IDs for deep linking  
🔍 **Stack Inspection** - Query the navigation stack programmatically  
🎨 **UIKit Integration** - Full access to UINavigationController customization  
⚡️ **SwiftUI Native** - Works seamlessly with SwiftUI state management  

## Installation

### Swift Package Manager

Add SwiftUINavKit to your project via Xcode:

1. File → Add Package Dependencies
2. Enter: `https://github.com/kusalrajapaksha/SwiftUINavKit.git`
3. Select version and add to your target

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/kusalrajapaksha/SwiftUINavKit.git", from: "1.0.0")
]
```

## Quick Start

```swift
import SwiftUI
import SwiftUINavKit

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @StateObject private var router = NavigationRouter()
    
    var body: some View {
        NavigationContainer(router: router, rootView: HomeView())
    }
}

struct HomeView: View {
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Go to Detail") {
                router.push(DetailView())
            }
            
            Button("Go to Settings") {
                router.push(SettingsView(), routeID: "settings")
            }
        }
        .navigationTitle("Home")
    }
}

struct DetailView: View {
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Go Back") {
                router.pop()
            }
            
            Button("Pop to Home") {
                router.popToView(HomeView.self)
            }
            
            Button("Pop to Root") {
                router.popToRoot()
            }
        }
        .navigationTitle("Detail")
    }
}
```

## Core Features

### Push Navigation

```swift
// Basic push
router.push(ProfileView())

// Push with route ID for deep linking
router.push(ProductDetailView(id: productID), routeID: "product-\(productID)")

// Push without animation
router.push(SettingsView(), animated: false)
```

### Pop Navigation

```swift
// Pop one level
router.pop()

// Pop multiple levels
router.pop(levels: 2)

// Pop to root
router.popToRoot()

// Pop to specific view type
router.popToView(HomeView.self)

// Pop to specific route ID
router.popToRoute(id: "checkout-start")
```

### Stack Inspection

```swift
// Check if route exists
if router.containsRoute(id: "user-profile") {
    router.popToRoute(id: "user-profile")
}

// Check if view type exists
if router.containsView(SettingsView.self) {
    router.popToView(SettingsView.self)
}

// Get current stack depth
print("Stack depth: \(router.stackDepth)")

// Debug the navigation stack
print(router.debugStack)
// Output: ["HomeView", "ProfileView", "SettingsView"]
```

### Custom Navigation Bar

```swift
NavigationContainer(router: router, rootView: HomeView()) { nav in
    // Customize navigation bar appearance
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .systemBlue
    
    nav.navigationBar.standardAppearance = appearance
    nav.navigationBar.scrollEdgeAppearance = appearance
    nav.navigationBar.prefersLargeTitles = true
    nav.navigationBar.tintColor = .white
}
```

## Advanced Usage

### Deep Linking

```swift
func handleDeepLink(url: URL) {
    let routeID = parseRouteID(from: url)
    
    if !router.containsRoute(id: routeID) {
        router.push(destinationView, routeID: routeID)
    } else {
        router.popToRoute(id: routeID)
    }
}
```

### Multi-Step Flows

```swift
// Checkout flow
router.push(CheckoutCartView(), routeID: "checkout-cart")
router.push(CheckoutShippingView(), routeID: "checkout-shipping")
router.push(CheckoutPaymentView(), routeID: "checkout-payment")

// Jump back to shipping
router.popToRoute(id: "checkout-shipping")
```

### Navigation from ViewModels

```swift
class ProductViewModel: ObservableObject {
    weak var router: NavigationRouter?
    
    func selectProduct(_ product: Product) {
        router?.push(
            ProductDetailView(product: product),
            routeID: "product-\(product.id)"
        )
    }
}
```

## Documentation

For detailed documentation and examples, see:
- [Complete Usage Guide](Documentation/USAGE.md)
- [Example Project](Examples/)
- [API Reference](Documentation/API.md)

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 5.9+
- Xcode 15.0+

## Why SwiftUINavKit?

SwiftUI's native `NavigationStack` works great for simple navigation, but falls short when you need:

- **Programmatic navigation** from ViewModels or services
- **Complex navigation flows** like wizards or multi-step forms
- **Deep linking** support
- **Custom navigation bar** styling beyond SwiftUI's capabilities
- **Stack inspection** and manipulation
- **Integration with UIKit** navigation patterns

SwiftUINavKit solves all of these while maintaining a clean, SwiftUI-friendly API.

## Examples

Check out the [Examples](Examples/) folder for:
- Basic navigation flow
- Multi-step wizard
- Deep linking implementation
- Tab bar integration
- Custom navigation bar styling

## License

SwiftUINavKit is available under the MIT license. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## Support

- 📫 [Open an issue](https://github.com/YourUsername/SwiftUINavKit/issues)
- 💬 [Discussions](https://github.com/YourUsername/SwiftUINavKit/discussions)
- 🐦 [Twitter](https://twitter.com/yourhandle)

## Author

**Your Name**
- GitHub: [@YourUsername](https://github.com/YourUsername)
- Twitter: [@yourhandle](https://twitter.com/yourhandle)

## Acknowledgments

Built with ❤️ for the SwiftUI community.

---

⭐️ If you find SwiftUINavKit helpful, please consider giving it a star!
