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
    func fetchEnrichment(seriesId: String, title: String) async throws -> EnrichmentJob?
    func fetchEpisodeMetadata(episodeId: String) async throws -> ExistingMetadata
    func approvedJob() async throws
    func fetchSeriesMetaData(seriesId: String) async throws -> ExistingMetadata
    func createURL(url: URL, path: String, urlQueryItems: [URLQueryItem]?) throws -> URL
    func createURLRequest(url: URL, method: RequestMethod, body: [String: Any]?) throws -> URLRequest
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
    private let enrichmentBaseUrl = URL(string: "https://x5z10lwlr0.execute-api.ap-southeast-2.amazonaws.com/prod/")!
    private let metadataBaseUrl = URL(string: "https://videometadataquery-uat.sandbox.inferno.digital/api/")!
    
    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchEnrichments() async throws -> [EnrichmentJob] {
        let path = "jobs"
        let url = try createURL(url: enrichmentBaseUrl, path: path)
        let request = try createURLRequest(url: url, method: .get)
        let (data, response) = try await session.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let enrichmentJobs = try JSONDecoder().decode([EnrichmentJob].self, from: data)
            return enrichmentJobs
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchEnrichment(seriesId: String, title: String) async throws -> EnrichmentJob? {
        let path = "jobs/series/\(seriesId)"
        let url = try createURL(url: enrichmentBaseUrl, path: path)
        let body: [String : Any] = [
            "Title": title
        ]
        let request = try createURLRequest(url: url, method: .post, body: body)
        let (data, response) = try await session.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
//            let enrichment = try JSONDecoder().decode(Enrich, from: <#T##Data#>)
        }
    }
    
    func approvedJob(jobId: String) async throws {
        let path = "jobs/\(jobId)/approve"
        let url = try createURL(url: enrichmentBaseUrl, path: path)
        let request = try createURLRequest(url: url, method: .post)
        let (data, response) = try await session.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
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
    
    func createURLRequest(url: URL, method: RequestMethod, body: [String: Any]? = nil) throws -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        if let body {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }
        return urlRequest
    }
}
