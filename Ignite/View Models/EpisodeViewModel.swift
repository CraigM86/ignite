//
//  EpisodeViewModel.swift
//  Ignite
//
//  Created by Craig Martin on 2/3/2026.
//

import Combine
import Foundation

class EpisodeViewModel: ObservableObject {
    @Published var episodeMetadata: ExistingMetadata? = nil
    
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchEpisode(episodeId: String) {
        Task {
            episodeMetadata = try await networkManager.fetchEpisodeMetadata(episodeId: episodeId)
        }
    }
}
