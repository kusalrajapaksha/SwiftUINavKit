//
//  Coordinator.swift
//  SwiftUINavKit
//
//  Created by Kusal on 2026-02-14.
//

public protocol Coordinator: AnyObject {
    var router: NavigationRouter { get }
    func start()
}
