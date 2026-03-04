//
//  SeriesViewModel.swift
//  Ignite
//
//  Created by Craig Martin on 2/3/2026.
//

import Combine
import Foundation

class SeriesViewModel: ObservableObject {
    @Published var seriesMetadata: ExistingMetadata? = nil
    @Published var isLoading = false
//    @Published var aiPopulatedData: EnrichmentJob?
    @Published var leadActors = ""
    @Published var actors = ""
    @Published var guestStars = ""
    @Published var directors = ""
    @Published var additionalSearch = ""

    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getSeries(seriesId: String)  {
        Task {
            seriesMetadata = try await networkManager.fetchSeriesMetaData(seriesId: seriesId)
        }
    }
    
    func retryAndFetchSeries(seriesId: String, title: String)  {
        Task {
            isLoading = true
            do {
                let success = try await networkManager.retry(jobId: seriesId, title: title)
                let enrichmentJob = try await networkManager.fetchEnrichment(jobId: seriesId)
                
                let leadActorsValue = enrichmentJob?.enrichments
                    .first { $0.property == .leadActors }
                    .map { $0.value.joined }
                
                let actorsValue = enrichmentJob?.enrichments
                    .first { $0.property == .actors }
                    .map { $0.value.joined }
                
                let guestStarsValue = enrichmentJob?.enrichments
                    .first { $0.property == .guestStars }
                    .map { $0.value.joined }
                
                let directorsValue = enrichmentJob?.enrichments
                    .first { $0.property == .directors }
                    .map { $0.value.joined }
                
                let additionalSearchValue = enrichmentJob?.enrichments
                    .first { $0.property == .additionalSearchTerm }
                    .map { $0.value.joined }
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    leadActors = leadActorsValue ?? ""
                    actors = actorsValue ?? ""
                    guestStars = guestStarsValue ?? ""
                    directors = directorsValue ?? ""
                    additionalSearch = additionalSearchValue ?? ""
                }
            } catch {
                
            }
            isLoading = false
        }
    }
}
