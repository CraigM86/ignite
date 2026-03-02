//
//  ContentView.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @State private var selectedOption: Int = 0
    
    var body: some View {
        EnrichmentListingsView(networkManager: networkManager)
    }
}
