//
//  EnrichmentListingsViewModel.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import Combine
import Foundation

class EnrichmentListingsViewModel: ObservableObject {
    @Published var listings: [EnrichmentJob] = []
    
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getListings() {
        Task {
            listings = try await networkManager.fetchEnrichments()
        }
    }
    
}
