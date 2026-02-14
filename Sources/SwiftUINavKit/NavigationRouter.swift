//
//  NavigationRouter.swift
//  SwiftUINavKit
//
//  Created by Kusal on 2026-02-14.
//

import SwiftUI
import UIKit

// MARK: - Hosting Wrapper
// We wrap SwiftUI views so we can identify them later in the stack.
@MainActor
final class RouteHostingController<Content: View>: UIHostingController<Content> {

    let viewTypeName: String
    let routeID: String?

    init(rootView: Content, routeID: String? = nil) {
        self.viewTypeName = String(describing: Content.self)
        self.routeID = routeID
        super.init(rootView: rootView)
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Marker Protocol
// Allows us to read viewTypeName and routeID generically.
protocol RouteHostingControllerMarker: AnyObject {
    var viewTypeName: String { get }
    var routeID: String? { get }
}

extension RouteHostingController: RouteHostingControllerMarker {}

// MARK: - Router
@MainActor
public final class NavigationRouter: ObservableObject {

    public weak var navigationController: UINavigationController?

    public init() {}

    // MARK: - Push SwiftUI View
    
    /// Pushes a SwiftUI view onto the navigation stack
    /// - Parameters:
    ///   - view: The SwiftUI view to push
    ///   - routeID: Optional identifier for this route (useful for deep linking or programmatic navigation)
    ///   - animated: Whether to animate the transition
    ///   - injectRouter: Whether to inject this router as an environment object
    @discardableResult
    public func push<V: View>(
        _ view: V,
        routeID: String? = nil,
        animated: Bool = true,
        injectRouter: Bool = true
    ) -> Bool {
        guard let nav = navigationController else { return false }
        
        let rootView = injectRouter ? AnyView(view.environmentObject(self)) : AnyView(view)
        let hosting = RouteHostingController(rootView: rootView, routeID: routeID)
        
        nav.pushViewController(hosting, animated: animated)
        return true
    }

    // MARK: - Pop Operations
    
    /// Pops the top view controller from the navigation stack
    /// - Parameter animated: Whether to animate the transition
    /// - Returns: True if a view controller was popped, false otherwise
    @discardableResult
    public func pop(animated: Bool = true) -> Bool {
        guard let popped = navigationController?.popViewController(animated: animated) else {
            return false
        }
        return popped != nil
    }

    /// Pops multiple view controllers from the navigation stack
    /// - Parameters:
    ///   - levels: Number of view controllers to pop
    ///   - animated: Whether to animate the transition
    /// - Returns: True if the operation succeeded, false otherwise
    @discardableResult
    public func pop(levels: Int, animated: Bool = true) -> Bool {
        guard
            let nav = navigationController,
            levels > 0,
            nav.viewControllers.count > levels
        else { return false }

        let targetIndex = nav.viewControllers.count - levels - 1
        let target = nav.viewControllers[targetIndex]
        
        let popped = nav.popToViewController(target, animated: animated)
        return popped != nil
    }

    /// Pops to the root view controller
    /// - Parameter animated: Whether to animate the transition
    /// - Returns: True if view controllers were popped, false otherwise
    @discardableResult
    public func popToRoot(animated: Bool = true) -> Bool {
        guard let popped = navigationController?.popToRootViewController(animated: animated) else {
            return false
        }
        return popped != nil
    }

    // MARK: - Targeted Navigation
    
    /// Pops to a specific SwiftUI view type in the stack
    /// - Parameters:
    ///   - viewType: The type of SwiftUI view to pop to
    ///   - animated: Whether to animate the transition
    /// - Returns: True if the target view was found and popped to, false otherwise
    @discardableResult
    public func popToView<V: View>(
        _ viewType: V.Type,
        animated: Bool = true
    ) -> Bool {
        guard let nav = navigationController else { return false }

        let targetName = String(describing: viewType)

        guard let target = nav.viewControllers.first(where: {
            ($0 as? RouteHostingControllerMarker)?.viewTypeName == targetName
        }) else {
            return false
        }
        
        let popped = nav.popToViewController(target, animated: animated)
        return popped != nil
    }

    /// Pops to a specific route by its identifier
    /// - Parameters:
    ///   - id: The route identifier to pop to
    ///   - animated: Whether to animate the transition
    /// - Returns: True if the route was found and popped to, false otherwise
    @discardableResult
    public func popToRoute(id: String, animated: Bool = true) -> Bool {
        guard let nav = navigationController else { return false }
        
        guard let target = nav.viewControllers.first(where: {
            ($0 as? RouteHostingControllerMarker)?.routeID == id
        }) else {
            return false
        }
        
        let popped = nav.popToViewController(target, animated: animated)
        return popped != nil
    }
    
    // MARK: - Stack Inspection
    
    /// Checks if a specific route ID exists in the navigation stack
    /// - Parameter id: The route identifier to search for
    /// - Returns: True if the route exists in the stack
    public func containsRoute(id: String) -> Bool {
        guard let nav = navigationController else { return false }
        
        return nav.viewControllers.contains(where: {
            ($0 as? RouteHostingControllerMarker)?.routeID == id
        })
    }
    
    /// Checks if a specific view type exists in the navigation stack
    /// - Parameter viewType: The SwiftUI view type to search for
    /// - Returns: True if the view type exists in the stack
    public func containsView<V: View>(_ viewType: V.Type) -> Bool {
        guard let nav = navigationController else { return false }
        
        let targetName = String(describing: viewType)
        return nav.viewControllers.contains(where: {
            ($0 as? RouteHostingControllerMarker)?.viewTypeName == targetName
        })
    }
    
    /// The current depth of the navigation stack
    public var stackDepth: Int {
        navigationController?.viewControllers.count ?? 0
    }
    
    /// Debug representation of the navigation stack (view type names only)
    public var debugStack: [String] {
        navigationController?.viewControllers.compactMap {
            ($0 as? RouteHostingControllerMarker)?.viewTypeName
        } ?? []
    }
    
    /// Enhanced debug representation including both type names and route IDs
    public var debugStackDetailed: [(type: String, id: String?)] {
        navigationController?.viewControllers.compactMap { vc in
            guard let marker = vc as? RouteHostingControllerMarker else { return nil }
            return (type: marker.viewTypeName, id: marker.routeID)
        } ?? []
    }
}

// MARK: - SwiftUI Environment Key
public struct NavigationRouterKey: EnvironmentKey {
    public static let defaultValue: NavigationRouter? = nil
}

public extension EnvironmentValues {
    var navigationRouter: NavigationRouter? {
        get { self[NavigationRouterKey.self] }
        set { self[NavigationRouterKey.self] = newValue }
    }
}

// MARK: - Convenience View Extension
public extension View {
    /// Injects a NavigationRouter into the environment
    func navigationRouter(_ router: NavigationRouter) -> some View {
        self.environment(\.navigationRouter, router)
    }
}
