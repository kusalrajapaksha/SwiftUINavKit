# SwiftUINavKit - Complete Usage Guide

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [Core Components](#core-components)
5. [Navigation Operations](#navigation-operations)
6. [Advanced Usage](#advanced-usage)
7. [Best Practices](#best-practices)
8. [Common Patterns](#common-patterns)
9. [Troubleshooting](#troubleshooting)
10. [API Reference](#api-reference)

---

## Overview

**SwiftUINavKit** is a powerful navigation router that bridges UIKit's `UINavigationController` with SwiftUI, providing programmatic navigation with type-safety and full UIKit customization.

### Key Features

- **Programmatic Navigation**: Push and pop views from anywhere in your app
- **Type-Safe**: Navigate to specific view types with compile-time safety
- **Route Identification**: Assign custom IDs to routes for deep linking and complex flows
- **Stack Inspection**: Query the navigation stack programmatically
- **UIKit Integration**: Full access to `UINavigationController` for customization
- **SwiftUI Native**: Works seamlessly with SwiftUI views and state management

### When to Use SwiftUINavKit

✅ **Use when you need:**
- Programmatic navigation (navigate from ViewModels, services, or deep in the view hierarchy)
- Complex navigation flows (multi-step forms, wizards, onboarding)
- Deep linking support
- Custom navigation bar styling beyond SwiftUI's capabilities
- Integration with existing UIKit navigation patterns

❌ **Don't use when:**
- Simple declarative navigation is sufficient (use `NavigationStack` instead)
- You're building a pure SwiftUI app with minimal navigation requirements

---

## Installation

### Swift Package Manager

Add SwiftUINavKit to your project via SPM:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftUINavKit.git", from: "1.0.0")
]
```

### Manual Installation

Copy the following files into your project:
- `NavigationRouter.swift`
- `NavigationContainer.swift`

---

## Quick Start

### Basic Setup

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
```

### Creating Your First View

```swift
struct HomeView: View {
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Home Screen")
                .font(.largeTitle)
            
            Button("Go to Detail") {
                router.push(DetailView())
            }
        }
        .navigationTitle("Home")
    }
}

struct DetailView: View {
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Detail Screen")
                .font(.largeTitle)
            
            Button("Go Back") {
                router.pop()
            }
            
            Button("Go to Settings") {
                router.push(SettingsView())
            }
        }
        .navigationTitle("Detail")
    }
}
```

---

## Core Components

### NavigationRouter

The main router class that handles all navigation operations.

```swift
@MainActor
public final class NavigationRouter: ObservableObject {
    public weak var navigationController: UINavigationController?
    
    // Navigation methods
    public func push<V: View>(_ view: V, routeID: String? = nil, animated: Bool = true, injectRouter: Bool = true) -> Bool
    public func pop(animated: Bool = true) -> Bool
    public func pop(levels: Int, animated: Bool = true) -> Bool
    public func popToRoot(animated: Bool = true) -> Bool
    public func popToView<V: View>(_ viewType: V.Type, animated: Bool = true) -> Bool
    public func popToRoute(id: String, animated: Bool = true) -> Bool
    
    // Stack inspection
    public func containsRoute(id: String) -> Bool
    public func containsView<V: View>(_ viewType: V.Type) -> Bool
    public var stackDepth: Int { get }
    public var debugStack: [String] { get }
    public var debugStackDetailed: [(type: String, id: String?)] { get }
}
```

### NavigationContainer

A UIViewControllerRepresentable that wraps the root view and provides the UINavigationController.

```swift
public struct NavigationContainer<Root: View>: UIViewControllerRepresentable {
    let router: NavigationRouter
    let rootView: Root
    let configure: ((UINavigationController) -> Void)?
    
    public init(
        router: NavigationRouter,
        rootView: Root,
        configure: ((UINavigationController) -> Void)? = nil
    )
}
```

---

## Navigation Operations

### Push Navigation

Push a new view onto the navigation stack:

```swift
// Basic push
router.push(ProfileView())

// Push with route ID
router.push(ProductDetailView(id: productID), routeID: "product-\(productID)")

// Push without animation
router.push(SettingsView(), animated: false)

// Push without auto-injecting router
router.push(ExternalView(), injectRouter: false)
```

### Pop Navigation

Remove views from the navigation stack:

```swift
// Pop one level
router.pop()

// Pop multiple levels
router.pop(levels: 2)  // Go back 2 screens

// Pop to root
router.popToRoot()

// Pop to specific view type
router.popToView(HomeView.self)

// Pop to specific route ID
router.popToRoute(id: "checkout-start")
```

### Result Handling

All navigation methods return `Bool` indicating success:

```swift
if router.push(DetailView()) {
    print("Navigation successful")
} else {
    print("Navigation failed - router not initialized")
}

// Check before popping
guard router.pop() else {
    print("Already at root")
    return
}
```

---

## Advanced Usage

### Route Identification

Assign custom IDs to routes for complex navigation flows:

```swift
// Multi-step checkout flow
router.push(CheckoutCartView(), routeID: "checkout-cart")
router.push(CheckoutShippingView(), routeID: "checkout-shipping")
router.push(CheckoutPaymentView(), routeID: "checkout-payment")
router.push(CheckoutConfirmationView(), routeID: "checkout-confirmation")

// Jump back to shipping from confirmation
router.popToRoute(id: "checkout-shipping")
```

### Deep Linking

Handle deep links by checking if routes exist:

```swift
func handleDeepLink(url: URL) {
    // Parse URL and extract route info
    let routeID = parseRouteID(from: url)
    
    // Navigate if route doesn't exist
    if !router.containsRoute(id: routeID) {
        router.push(destinationView, routeID: routeID)
    } else {
        router.popToRoute(id: routeID)
    }
}
```

### Stack Inspection

Query the navigation stack programmatically:

```swift
// Check current depth
if router.stackDepth > 3 {
    print("Deep in navigation hierarchy")
}

// Check if specific route exists
if router.containsRoute(id: "user-profile") {
    print("User profile is in the stack")
}

// Check if view type exists
if router.containsView(SettingsView.self) {
    router.popToView(SettingsView.self)
} else {
    router.push(SettingsView())
}

// Debug current stack
print("Current stack:", router.debugStack)
// Output: ["HomeView", "AnyView", "DetailView"]

print("Detailed stack:", router.debugStackDetailed)
// Output: [(type: "HomeView", id: nil), (type: "AnyView", id: "product-123"), (type: "DetailView", id: nil)]
```

### Custom Navigation Bar

Customize the UINavigationController appearance:

```swift
struct ContentView: View {
    @StateObject private var router = NavigationRouter()
    
    var body: some View {
        NavigationContainer(router: router, rootView: HomeView()) { nav in
            // Configure navigation bar appearance
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBlue
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            
            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.scrollEdgeAppearance = appearance
            nav.navigationBar.compactAppearance = appearance
            nav.navigationBar.prefersLargeTitles = true
            nav.navigationBar.tintColor = .white
        }
    }
}
```

### Environment Access

Access the router via SwiftUI environment:

```swift
struct ProfileView: View {
    @Environment(\.navigationRouter) var router
    
    var body: some View {
        Button("Navigate") {
            router?.push(SettingsView())
        }
    }
}

// Set router in environment
MyView()
    .navigationRouter(router)
```

---

## Best Practices

### 1. Router Lifecycle Management

```swift
// ✅ GOOD: Create router at app/scene level
@main
struct MyApp: App {
    @StateObject private var router = NavigationRouter()
    
    var body: some Scene {
        WindowGroup {
            NavigationContainer(router: router, rootView: ContentView())
        }
    }
}

// ❌ BAD: Creating router per view
struct SomeView: View {
    @StateObject private var router = NavigationRouter()  // Don't do this
    var body: some View { ... }
}
```

### 2. Route ID Naming Conventions

```swift
// ✅ GOOD: Descriptive, unique IDs
router.push(ProductDetailView(id: 123), routeID: "product-detail-123")
router.push(UserProfileView(userID: "abc"), routeID: "user-profile-abc")
router.push(CheckoutStepView(step: 2), routeID: "checkout-step-2")

// ❌ BAD: Generic or duplicate IDs
router.push(SomeView(), routeID: "view")  // Too generic
router.push(DetailView(), routeID: "detail")  // Might have duplicates
```

### 3. Error Handling

```swift
// ✅ GOOD: Check results for critical navigation
func proceedToCheckout() {
    guard router.push(CheckoutView(), routeID: "checkout") else {
        showAlert("Unable to proceed to checkout")
        return
    }
    analytics.track("checkout_started")
}

// ✅ GOOD: Graceful fallback
func navigateToProfile() {
    if router.containsView(ProfileView.self) {
        router.popToView(ProfileView.self)
    } else {
        router.push(ProfileView())
    }
}
```

### 4. Clean Navigation Flows

```swift
// ✅ GOOD: Clear navigation intent
func completeOnboarding() {
    router.popToRoot()
    router.push(MainTabView(), routeID: "main")
}

// ✅ GOOD: Conditional navigation
func handleLoginSuccess() {
    if router.containsRoute(id: "protected-content") {
        router.popToRoute(id: "protected-content")
    } else {
        router.popToRoot()
    }
}
```

### 5. Memory Management

```swift
// ✅ GOOD: Router is weak reference to UINavigationController
// ✅ GOOD: Views hold router as @EnvironmentObject (managed by SwiftUI)

// ❌ BAD: Don't create strong reference cycles
class ViewModel {
    let router: NavigationRouter  // Avoid if ViewModel is retained elsewhere
}

// ✅ GOOD: Use weak or unowned if needed
class ViewModel {
    weak var router: NavigationRouter?
}
```

---

## Common Patterns

### Pattern 1: Wizard/Multi-Step Flow

```swift
struct OnboardingCoordinator {
    let router: NavigationRouter
    
    func startOnboarding() {
        router.push(OnboardingStep1View(), routeID: "onboarding-1")
    }
    
    func nextStep(_ currentStep: Int) {
        switch currentStep {
        case 1:
            router.push(OnboardingStep2View(), routeID: "onboarding-2")
        case 2:
            router.push(OnboardingStep3View(), routeID: "onboarding-3")
        case 3:
            completeOnboarding()
        default:
            break
        }
    }
    
    func skipToEnd() {
        completeOnboarding()
    }
    
    private func completeOnboarding() {
        router.popToRoot()
        router.push(MainAppView())
    }
}
```

### Pattern 2: Conditional Navigation

```swift
struct ContentView: View {
    @EnvironmentObject var router: NavigationRouter
    @State private var isLoggedIn = false
    
    var body: some View {
        Button("View Profile") {
            if isLoggedIn {
                router.push(ProfileView())
            } else {
                router.push(LoginView(), routeID: "login")
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var router: NavigationRouter
    
    func handleLoginSuccess() {
        // Return to where user came from
        router.pop()
        // Then navigate to profile
        router.push(ProfileView())
    }
}
```

### Pattern 3: Tab Bar with Deep Navigation

```swift
struct MainTabView: View {
    @StateObject private var homeRouter = NavigationRouter()
    @StateObject private var searchRouter = NavigationRouter()
    @StateObject private var profileRouter = NavigationRouter()
    
    var body: some View {
        TabView {
            NavigationContainer(router: homeRouter, rootView: HomeView())
                .tabItem { Label("Home", systemImage: "house") }
            
            NavigationContainer(router: searchRouter, rootView: SearchView())
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
            
            NavigationContainer(router: profileRouter, rootView: ProfileView())
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
```

### Pattern 4: Navigation from ViewModel

```swift
class ProductViewModel: ObservableObject {
    weak var router: NavigationRouter?
    
    func selectProduct(_ product: Product) {
        router?.push(
            ProductDetailView(product: product),
            routeID: "product-\(product.id)"
        )
    }
    
    func proceedToCheckout() {
        guard router?.push(CheckoutView(), routeID: "checkout") == true else {
            // Handle error
            return
        }
    }
}

struct ProductListView: View {
    @StateObject private var viewModel = ProductViewModel()
    @EnvironmentObject var router: NavigationRouter
    
    var body: some View {
        List(viewModel.products) { product in
            Button(product.name) {
                viewModel.selectProduct(product)
            }
        }
        .onAppear {
            viewModel.router = router
        }
    }
}
```

### Pattern 5: Deep Link Handling

```swift
class DeepLinkHandler {
    let router: NavigationRouter
    
    init(router: NavigationRouter) {
        self.router = router
    }
    
    func handle(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        switch components.path {
        case "/product":
            if let productID = components.queryItems?.first(where: { $0.name == "id" })?.value {
                navigateToProduct(id: productID)
            }
        case "/user":
            if let userID = components.queryItems?.first(where: { $0.name == "id" })?.value {
                navigateToUser(id: userID)
            }
        default:
            break
        }
    }
    
    private func navigateToProduct(id: String) {
        let routeID = "product-\(id)"
        
        if router.containsRoute(id: routeID) {
            router.popToRoute(id: routeID)
        } else {
            router.popToRoot()
            router.push(ProductDetailView(productID: id), routeID: routeID)
        }
    }
    
    private func navigateToUser(id: String) {
        // Similar implementation
    }
}
```

---

## Troubleshooting

### Router Not Working

**Problem:** Navigation methods do nothing or return `false`.

**Solution:**
```swift
// Check if router is initialized
if router.navigationController == nil {
    print("Router not connected to navigation controller")
}

// Ensure NavigationContainer is used
NavigationContainer(router: router, rootView: HomeView())  // ✅
// Not: NavigationStack { HomeView() }  // ❌
```

### Views Not Receiving Router

**Problem:** `@EnvironmentObject var router: NavigationRouter` crashes with "No ObservableObject found".

**Solution:**
```swift
// Make sure router is injected
router.push(MyView(), injectRouter: true)  // ✅ Default behavior

// Or inject manually
MyView()
    .environmentObject(router)
```

### Navigation Animation Issues

**Problem:** Animations are janky or views flash.

**Solution:**
```swift
// Ensure all navigation happens on main thread
@MainActor
func navigate() {
    router.push(NextView())
}

// The router is already @MainActor, so this is handled automatically
```

### Memory Leaks

**Problem:** Views or routers not being deallocated.

**Solution:**
```swift
// ✅ Router's navigationController is weak
public weak var navigationController: UINavigationController?

// ✅ Use @EnvironmentObject in views
@EnvironmentObject var router: NavigationRouter

// ❌ Don't create strong reference cycles
class MyViewModel {
    weak var router: NavigationRouter?  // Use weak
}
```

### Stack Depth Issues

**Problem:** Can't pop the expected number of levels.

**Solution:**
```swift
// Check stack depth first
if router.stackDepth > 3 {
    router.pop(levels: 2)
} else {
    router.popToRoot()
}

// Debug the stack
print("Current stack:", router.debugStackDetailed)
```

---

## API Reference

### NavigationRouter Methods

#### push

```swift
@discardableResult
public func push<V: View>(
    _ view: V,
    routeID: String? = nil,
    animated: Bool = true,
    injectRouter: Bool = true
) -> Bool
```

Pushes a new view onto the navigation stack.

**Parameters:**
- `view`: The SwiftUI view to push
- `routeID`: Optional identifier for this route
- `animated`: Whether to animate the transition (default: `true`)
- `injectRouter`: Whether to inject this router as an environment object (default: `true`)

**Returns:** `true` if push succeeded, `false` if router is not initialized

---

#### pop

```swift
@discardableResult
public func pop(animated: Bool = true) -> Bool
```

Pops the top view from the navigation stack.

**Parameters:**
- `animated`: Whether to animate the transition (default: `true`)

**Returns:** `true` if a view was popped, `false` otherwise

---

#### pop(levels:)

```swift
@discardableResult
public func pop(levels: Int, animated: Bool = true) -> Bool
```

Pops multiple views from the navigation stack.

**Parameters:**
- `levels`: Number of views to pop
- `animated`: Whether to animate the transition (default: `true`)

**Returns:** `true` if operation succeeded, `false` otherwise

---

#### popToRoot

```swift
@discardableResult
public func popToRoot(animated: Bool = true) -> Bool
```

Pops to the root view controller.

**Parameters:**
- `animated`: Whether to animate the transition (default: `true`)

**Returns:** `true` if views were popped, `false` otherwise

---

#### popToView

```swift
@discardableResult
public func popToView<V: View>(
    _ viewType: V.Type,
    animated: Bool = true
) -> Bool
```

Pops to a specific SwiftUI view type in the stack.

**Parameters:**
- `viewType`: The type of view to pop to
- `animated`: Whether to animate the transition (default: `true`)

**Returns:** `true` if target view was found and popped to, `false` otherwise

---

#### popToRoute

```swift
@discardableResult
public func popToRoute(id: String, animated: Bool = true) -> Bool
```

Pops to a specific route by its identifier.

**Parameters:**
- `id`: The route identifier to pop to
- `animated`: Whether to animate the transition (default: `true`)

**Returns:** `true` if route was found and popped to, `false` otherwise

---

#### containsRoute

```swift
public func containsRoute(id: String) -> Bool
```

Checks if a specific route ID exists in the navigation stack.

**Parameters:**
- `id`: The route identifier to search for

**Returns:** `true` if the route exists in the stack

---

#### containsView

```swift
public func containsView<V: View>(_ viewType: V.Type) -> Bool
```

Checks if a specific view type exists in the navigation stack.

**Parameters:**
- `viewType`: The view type to search for

**Returns:** `true` if the view type exists in the stack

---

### NavigationRouter Properties

#### stackDepth

```swift
public var stackDepth: Int { get }
```

The current depth of the navigation stack.

---

#### debugStack

```swift
public var debugStack: [String] { get }
```

Debug representation showing view type names in the stack.

**Example:**
```swift
print(router.debugStack)
// Output: ["HomeView", "AnyView", "DetailView"]
```

---

#### debugStackDetailed

```swift
public var debugStackDetailed: [(type: String, id: String?)] { get }
```

Enhanced debug representation showing both type names and route IDs.

**Example:**
```swift
print(router.debugStackDetailed)
// Output: [(type: "HomeView", id: nil), (type: "AnyView", id: "product-123")]
```

---

### NavigationContainer

```swift
public struct NavigationContainer<Root: View>: UIViewControllerRepresentable {
    public init(
        router: NavigationRouter,
        rootView: Root,
        configure: ((UINavigationController) -> Void)? = nil
    )
}
```

A container that wraps your root SwiftUI view and provides UINavigationController integration.

**Parameters:**
- `router`: The NavigationRouter instance
- `rootView`: The root SwiftUI view
- `configure`: Optional closure to customize the UINavigationController

**Example:**
```swift
NavigationContainer(router: router, rootView: HomeView()) { nav in
    nav.navigationBar.prefersLargeTitles = true
    nav.navigationBar.tintColor = .blue
}
```

---

### Environment Values

```swift
@Environment(\.navigationRouter) var router: NavigationRouter?
```

Access the navigation router from SwiftUI environment.

**Example:**
```swift
struct MyView: View {
    @Environment(\.navigationRouter) var router
    
    var body: some View {
        Button("Navigate") {
            router?.push(NextView())
        }
    }
}
```

---

## License

MIT License - See LICENSE file for details

---

## Contributing

Contributions are welcome! Please submit issues and pull requests on GitHub.

---

## Support

For questions and support, please open an issue on the GitHub repository.
