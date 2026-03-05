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
    @Published var leadActors = ""
    @Published var leadActorsEnrichment: Enrichment?
    @Published var actors = ""
    @Published var actorsEnrichment: Enrichment?
    @Published var guestStars = ""
    @Published var guestStarsEnrichment: Enrichment?
    @Published var directors = ""
    @Published var directorsEnrichment: Enrichment?
    @Published var additionalSearch = ""
    @Published var additionalSearchEnrichment: Enrichment?
    @Published var validator: Validator?
    
    @Published var approvalSuccess: Bool? = nil
    @Published var approvalErrorMessage: String? = nil

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
                
                let leadActorsEnrichmentValue = enrichmentJob?.enrichments
                    .first { $0.property == .leadActors }
                
                let leadActorsValue = enrichmentJob?.enrichments
                    .first { $0.property == .leadActors }
                    .map { $0.value.joined }
                
                let actorsEnrichmentValue = enrichmentJob?.enrichments
                    .first { $0.property == .actors }
                
                let actorsValue = enrichmentJob?.enrichments
                    .first { $0.property == .actors }
                    .map { $0.value.joined }
                
                let guestStarsEnrichmentValue = enrichmentJob?.enrichments
                    .first { $0.property == .guestStars }
                
                let guestStarsValue = enrichmentJob?.enrichments
                    .first { $0.property == .guestStars }
                    .map { $0.value.joined }
                
                let directorsEnrichmentValue = enrichmentJob?.enrichments
                    .first { $0.property == .directors }
                
                let directorsValue = enrichmentJob?.enrichments
                    .first { $0.property == .directors }
                    .map { $0.value.joined }
                
                let additionalSearchEnrichmentValue = enrichmentJob?.enrichments
                    .first { $0.property == .additionalSearchTerm }
                
                let additionalSearchValue = enrichmentJob?.enrichments
                    .first { $0.property == .additionalSearchTerm }
                    .map { $0.value.joined }
                
                let validatorValue = enrichmentJob?.validator
                
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    leadActorsEnrichment = leadActorsEnrichmentValue
                    leadActors = leadActorsValue ?? ""
                    actorsEnrichment = actorsEnrichmentValue
                    actors = actorsValue ?? ""
                    guestStarsEnrichment = guestStarsEnrichmentValue
                    guestStars = guestStarsValue ?? ""
                    directorsEnrichment = directorsEnrichmentValue
                    directors = directorsValue ?? ""
                    additionalSearchEnrichment = additionalSearchEnrichmentValue
                    additionalSearch = additionalSearchValue ?? ""
                    validator = validatorValue
                }
            } catch {
                
            }
            isLoading = false
        }
    }
    
    func approveJob(
        seriesId: String,
        leadActors: String,
        actors: String,
        guestStars: String,
        directors: String,
        additionalSearch: String
    ) {
        let body: [String: Any] = [
            "leadActors": leadActors,
            "actors": actors,
            "guestStars": guestStars,
            "directors": directors,
            "additionalSearch": additionalSearch
        ]
        
        Task {
            isLoading = true
            do {
                try await networkManager.approveJob(jobId: seriesId, body: body)
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
