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
    
    @Published var shortSynopsisEnrichment: Enrichment?
    @Published var shortSynopsis = ""
    
    @Published var genreEnrichment: Enrichment?
    @Published var genre: [String] = []
    
    @Published var approvalSuccess: Bool? = nil
    @Published var approvalErrorMessage: String? = nil
    
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
                
                
                let shortSynopsisEnrichmentValue = enrichmentJob?.enrichments
                    .first { $0.property == .shortSynopsis }
                
                let shortSynopsisValue = enrichmentJob?.enrichments
                    .first { $0.property == .shortSynopsis }
                    .map { $0.value.joined }
                
                let genreEnrichmentValue = enrichmentJob?.enrichments
                    .first { $0.property == .genre }
                
                let genreValue = enrichmentJob?.enrichments
                    .first { $0.property == .genre }
                    .map { $0.value.values }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    shortSynopsisEnrichment = shortSynopsisEnrichmentValue
                    shortSynopsis = shortSynopsisValue ?? ""
                    genreEnrichment = genreEnrichmentValue
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
            isLoading = true
            do {
                try await networkManager.approveJob(jobId: episodeId, body: body)
                DispatchQueue.main.async { [weak self] in
                    self?.approvalSuccess = true
                    self?.approvalErrorMessage = nil
                    // Hide message after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self?.approvalSuccess = nil
                        self?.approvalErrorMessage = nil
                    }
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.approvalSuccess = false
                    self?.approvalErrorMessage = error.localizedDescription
                    // Hide message after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self?.approvalSuccess = nil
                        self?.approvalErrorMessage = nil
                    }
                }
            }
            isLoading = false
        }
    }
}
