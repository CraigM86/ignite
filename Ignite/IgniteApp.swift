//
//  IgniteApp.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import SwiftUI

@main
struct IgniteApp: App {
    @StateObject private var network = NetworkManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(network)
        }
    }
}
