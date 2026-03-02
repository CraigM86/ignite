//
//  ExistingMetadata.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import Foundation

struct ExistingMetadata: Decodable {
    let mediaType: String
    let title: String
    let extraShortSynopsis: String
    let shortSynopsis: String
    let classification: String
    let backgroundImageLogo: BackgroundImageLogo
    let genre: [String]
    let combinedGenres: [String]
}

struct BackgroundImageLogo: Decodable {
    let name: String
    let url: String
}
