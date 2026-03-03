//
//  EpisodeView.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import SwiftUI

struct EpisodeView: View {
    let episode: EnrichmentJob
    @StateObject private var episodeViewModel: EpisodeViewModel
    
    @State private var shortSynopsisArray: [String] = []
    @State private var shortSynopsis = ""
    @State private var shortSynopsisSelectedIndex = 0
    
    @State private var genreArray: [String]
    @State private var genre: String = []
    @State private var genreSelectedIndex: Int = 0
    
    init(episode: EnrichmentJob, networkManager: NetworkManager) {
        self.episode = episode
        let enrichments = episode.enrichments.first
        
//        let shortSynopsisValue = enrichments?
        
        _episodeViewModel = StateObject(wrappedValue: EpisodeViewModel(networkManager: networkManager))
    }
    
    var body: some View {
            ZStack {
                ScrollView {
                    VStack {
                        Text("Episode")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.igniteSoftPink, .igniteOrange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        TextCompareView(
                            header: "Short Synopsis",
                            storedArray: $shortSynopsisArray,
                            selectedIndex: $shortSynopsisSelectedIndex,
                            bedrockField: $shortSynopsis,
                            height: 140,
                            first: true
                        )
                        
                        TextCompareView(
                            header: "Genres",
                            storedArray: $genreArray,
                            selectedIndex: $genreSelectedIndex,
                            bedrockField: $genre,
                            height: 140
                        )
                        
                        if let metadata = episodeViewModel.seriesMetadata {
                            ExistingFieldsView(
                                header: "Title",
                                text: metadata.title,
                                height: 50
                            )
                            
                            ExistingFieldsView(
                                header: "Extra short synopsis",
                                text: metadata.extraShortSynopsis,
                                height: 140
                            )
                            
                            ExistingFieldsView(
                                header: "Short synopsis",
                                text: metadata.shortSynopsis,
                                height: 140
                            )
                            
                            ExistingFieldsView(
                                header: "Classification",
                                text: metadata.classification,
                                height: 50
                            )
                            
                            ExistingFieldsView(
                                header: "Background Image",
                                text: metadata.backgroundImageLogo.url,
                                height: 140
                            )
                        }
                        
                    }
                }
                .onAppear {
                    episodeViewModel.fetchEpisode(episodeId: episode.job)
                }
                .background(.igniteBlack)
                .overlay(alignment: .bottomTrailing) {
                    VStack(spacing: 32) {
                        Button {
                            isLoading = true
                        } label: {
                            Image(systemName: "wand.and.stars")
                                .foregroundStyle(.white)
                                .font(.system(size: 32))
                                .frame(width: 54, height: 54)
                                .background(
                                    Circle()
                                        .fill(.ignitePink)
                                )
                            
                        }
                        
                        Button {
                            print("button tapped")
                        } label: {
                            Image(systemName: "icloud.and.arrow.up")
                                .foregroundStyle(.white)
                                .font(.system(size: 32))
                                .frame(width: 54, height: 54)
                                .background(
                                    Circle()
                                        .fill(.igniteGreen)
                                )
                            
                        }
                    }
                    .padding(44)
                }
                
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .ignitePink))
                            .scaleEffect(2)
                        
                        Text("Loading...")
                            .foregroundStyle(.ignitePink)
                    }
                    .frame(width: 400, height: 400)
                    .background(.igniteBlack.opacity(0.5))
                }
            }
    }
}
