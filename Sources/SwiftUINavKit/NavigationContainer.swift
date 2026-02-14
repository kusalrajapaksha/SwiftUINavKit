//
//  NavigationContainer.swift
//  SwiftUINavKit
//
//  Created by Kusal on 2026-02-14.
//

import SwiftUI
import UIKit

public struct NavigationContainer<Root: View>: UIViewControllerRepresentable {

    let router: NavigationRouter
    let rootView: Root
    let configure: ((UINavigationController) -> Void)?

    public init(
        router: NavigationRouter,
        rootView: Root,
        configure: ((UINavigationController) -> Void)? = nil
    ) {
        self.router = router
        self.rootView = rootView
        self.configure = configure
    }

    public func makeUIViewController(context: Context) -> UINavigationController {
        let hosting = RouteHostingController(
            rootView: rootView.environmentObject(router)
        )

        let nav = UINavigationController(rootViewController: hosting)
        router.navigationController = nav
        
        // Apply custom configuration
        configure?(nav)

        return nav
    }

    public func updateUIViewController(
        _ uiViewController: UINavigationController,
        context: Context
    ) {
        // Update root view if needed
        if let hosting = uiViewController.viewControllers.first as? RouteHostingController<AnyView> {
            hosting.rootView = AnyView(rootView.environmentObject(router))
        }
    }
}
