//
//  NetworkManager.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import Combine
import Foundation

protocol NetworkManagerProtocol {
    func fetchEnrichments() async throws -> [EnrichmentJob]
    func fetchEpisodeMetadata(episodeId: String) async throws -> ExistingMetadata
    func fetchSeriesMetaData(seriesId: String) async throws -> ExistingMetadata
    func createURL(url: URL, path: String, urlQueryItems: [URLQueryItem]?) throws -> URL
    func createURLRequest(url: URL, method: RequestMethod) throws -> URLRequest
}

enum RequestMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case invalidResponse
    case serverError
    case requestError(String)
    case forbiddenAccessError(String)
    case decodingError
}


class NetworkManager: NetworkManagerProtocol, ObservableObject {
    
    private let session: URLSession
    private let enrichmentBaseUrl = URL(string: "https://enrichmentservicehost")!
    private let metadataBaseUrl = URL(string: "https://videometadataquery-uat.sandbox.inferno.digital/api/")!
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchEnrichments() async throws -> [EnrichmentJob] {
        return [
            EnrichmentJob(
                type: .series,
                contentName: "St. Denis Medical Center",
                job: "GRIM",
                status: .inProgress,
                enrichment:
                    Enrichment(
                        leadActors: "John Travolta, Tom Hanks",
                        actors: "",
                        guestStars: "",
                        directors: "RobertZemeckis",
                        additionalSearchTerm: "",
                        confidenceScore: 0.6,
                        source: "opus-4.6"
                    )
            ),
            EnrichmentJob(
                type: .episode,
                contentName: "Some episode",
                job: "GRIM-001",
                status: .approved,
                enrichment: Enrichment(
                    leadActors: "Tom and Jerry",
                    actors: "",
                    guestStars: "",
                    directors: "Quentin Tarantino",
                    additionalSearchTerm: "",
                    confidenceScore: 7.2,
                    source: "opus-4.6"
                )
            )
        ]
    }
    
    func fetchEpisodeMetadata(episodeId: String) async throws -> ExistingMetadata {
        let path = "media/episode/\(episodeId)"
        let url = try createURL(url: metadataBaseUrl, path: path)
        let request = try createURLRequest(url: url, method: .get)
        let (data, response) = try await session.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        do {
            let existingMetadata = try JSONDecoder().decode(ExistingMetadata.self, from: data)
            return existingMetadata
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchSeriesMetaData(seriesId: String) async throws -> ExistingMetadata {
        let path = "media/series/\(seriesId)"
        let url = try createURL(url: metadataBaseUrl, path: path)
        let request = try createURLRequest(url: url, method: .get)
        let (data, response) = try await session.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        do {
            let existingMetadata = try JSONDecoder().decode(ExistingMetadata.self, from: data)
            return existingMetadata
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func createURL(url: URL, path: String, urlQueryItems: [URLQueryItem]? = nil) throws -> URL {
        guard var urlComponents = URLComponents(url: url.appendingPathComponent(path), resolvingAgainstBaseURL: true) else {
            throw NetworkError.requestError("Couldn't build URL components")
        }
        if let queryitems = urlQueryItems {
            urlComponents.queryItems = queryitems
        }
        guard let url = urlComponents.url else {
            throw NetworkError.requestError("failed to construct url")
        }
        
        return url
    }
    
    func createURLRequest(url: URL, method: RequestMethod) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}
