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
    @Published var isLoading = false
    
    @Published var shortSynopsis = ""
    @Published var genre: [String] = []
    
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchEpisode(episodeId: String) {
        Task {
            episodeMetadata = try await networkManager.fetchEpisodeMetadata(episodeId: episodeId)
        }
    }
    
    func retryAndFetchEpisode(episodeId: String, title: String) {
        Task {
            isLoading = true
            do {
                let success = try await networkManager.retry(jobId: episodeId, title: title)
                let enrichmentJob = try await networkManager.fetchEnrichment(jobId: episodeId)
                
                let shortSynopsisValue = enrichmentJob?.enrichments
                    .first { $0.property == .shortSynopsis }
                    .map { $0.value.joined }
                
                let genreValue = enrichmentJob?.enrichments
                    .first { $0.property == .genre }
                    .map { $0.value.values }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    shortSynopsis = shortSynopsisValue ?? ""
                    genre = genreValue ?? []
                }
            } catch {
                
            }
            isLoading = false
        }
    }
    
    func approvedJob(episodeId: String, genres: [String], shortSynopsis: String) {
        let body: [String: Any] = [
            "genre": genres,
            "shortSynopsis": shortSynopsis
        ]
        
        Task {
            
            try await networkManager.approveJob(jobId: episodeId, body: body)
        }
        
    }
}
