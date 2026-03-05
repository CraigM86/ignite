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
    
    @State private var genreArray: [[String]] = []
    @State private var genreSelectedIndex: Int = 0
    
    init(episode: EnrichmentJob, networkManager: NetworkManager) {
        self.episode = episode
        
//        let shortSynopsisValue = episode.enrichments
//            .filter { $0.property == .shortSynopsis }
//            .flatMap { $0.value.values }
//        
//        let genreValue = episode.enrichments
//            .filter { $0.property == .genre }
//            .flatMap { $0.value.values }
//        
//        _shortSynopsisArray = State(initialValue: shortSynopsisValue)
//        _genreArray = State(initialValue: [genreValue])
//        
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
                    if let episodeMetadata = episodeViewModel.episodeMetadata {
                        Text((episodeMetadata.seriesTitle ?? "") + episodeMetadata.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(.igniteWhite)
                            .padding()
                    }
                    
                    TextCompareView(
                        header: "Short Synopsis",
                        storedArray: $shortSynopsisArray,
                        selectedIndex: $shortSynopsisSelectedIndex,
                        bedrockField: $episodeViewModel.shortSynopsis,
                        enrichment: $episodeViewModel.shortSynopsisEnrichment,
                        height: 200,
                        first: true
                    )
                    
                    TextCompareArrayView(
                        header: "Genres",
                        storedGenreArray: $genreArray,
                        selectedIndex: $genreSelectedIndex,
                        bedrockField: $episodeViewModel.genre,
                        enrichment: $episodeViewModel.genreEnrichment,
                        height: 200
                    )
                }
            }
            .onAppear {
                Task {
                    setupAIFields()
                    episodeViewModel.fetchEpisode(episodeId: episode.job)
                }
            }
            .onChange(of: episodeViewModel.episodeMetadata) { metadata in
                if let metadata = metadata {
                    shortSynopsisArray.append(metadata.shortSynopsis)
                    shortSynopsisSelectedIndex = shortSynopsisArray.count - 1
                    
                    genreArray.append(metadata.genre)
                    genreSelectedIndex = genreArray.count - 1
                }
            }
            .background(.igniteBlack)
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 32) {
                    Button {
                        episodeViewModel.retryAndFetchEpisode(
                            episodeId: episode.job,
                            title: episodeViewModel.episodeMetadata?.title
                            ?? episode.contentName
                        )
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
                        episodeViewModel.approvedJob(
                            episodeId: episode.job,
                            genres: genreArray[genreSelectedIndex],
                            shortSynopsis: shortSynopsisArray[shortSynopsisSelectedIndex]
                        )
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
            
            if episodeViewModel.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .ignitePink))
                        .scaleEffect(3)
                        .padding()
                    
                    Text("Loading...")
                        .foregroundStyle(.ignitePink)
                }
                .frame(width: 400, height: 400)
                .background(.igniteDarkGrey)
                .cornerRadius(24)
            }
        }
        
        if let success = episodeViewModel.approvalSuccess {
            if success {
                Text("Approval succeeded!")
                    .foregroundColor(.green)
                    .padding()
            } else {
                Text("Approval failed: \(episodeViewModel.approvalErrorMessage ?? "Unknown error")")
                    .foregroundColor(.red)
                    .padding()
            }
        }
    }
    
    private func setupAIFields() {
        let shortSynopsisValue = episode.enrichments
            .first { $0.property == .shortSynopsis }
            .map { $0.value.joined }
        
        let genreValue = episode.enrichments
            .first { $0.property == .genre }
            .map { $0.value.values }
        
        episodeViewModel.shortSynopsis = shortSynopsisValue ?? ""
        episodeViewModel.genre = genreValue ?? []
    }
}
