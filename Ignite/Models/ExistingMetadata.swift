//
//  ExistingMetadata.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import Foundation

struct ExistingMetadata: Decodable, Equatable {
    let mediaType: String
    let title: String
    let seriesTitle: String?
    let shortSynopsis: String
    let longSynopsis: String
    let classification: String?
    let leadActors: String?
    let actors: String?
    let guestStars: String?
    let directors: String?
    let additionalSearchTerm: String?
//    let backgroundImageLogo: BackgroundImageLogo
    let genre: [String]
    let combinedGenres: [String]
}

struct BackgroundImageLogo: Decodable {
    let name: String
    let url: String
}
