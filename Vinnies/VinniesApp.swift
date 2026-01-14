//
//  VinniesApp.swift
//  Vinnies
//

import SwiftUI

@main
struct VinniesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
