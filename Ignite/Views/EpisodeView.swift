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
    
    init(episode: EnrichmentJob, networkManager: NetworkManager) {
        self.episode = episode
        _episodeViewModel = StateObject(wrappedValue: EpisodeViewModel(networkManager: networkManager))
    }
    
    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                
            }
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
                    height: 80
                )
            }
        }
        .onAppear {
            episodeViewModel.fetchEpisode(episodeId: episode.job)
        }
    }
}
