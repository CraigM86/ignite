//
//  SeriesView.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import SwiftUI

struct SeriesView: View {
    let series: EnrichmentJob

    @StateObject private var seriesViewModel: SeriesViewModel
    
    @State private var leadActorsArray: [String]
    @State private var leadActorsSelectedIndex = 0
    
    @State private var actorsArray: [String] = []
    @State private var actorsSelectedIndex = 0
    
    @State private var guestStarsArray: [String] = []
    @State private var guestStarsSelectedIndex = 0
    
    @State private var directorsArray: [String] = []
    @State private var directorsSelectedIndex = 0
    
    @State private var additionalSearchArray: [String] = []
    @State private var additionalSearchSelectedIndex = 0
    
    init(series: EnrichmentJob, networkManager: NetworkManager) {
        self.series = series
     
        let leadActorsValue = series.enrichments
            .filter { $0.property == .leadActors }
            .flatMap { $0.value.values }
        
        let actorsValue = series.enrichments
            .filter { $0.property == .actors }
            .flatMap { $0.value.values }
        
        let guestStarsValue = series.enrichments
            .filter { $0.property == .guestStars }
            .flatMap { $0.value.values }
        
        let directorsValue = series.enrichments
            .filter { $0.property == .directors }
            .flatMap { $0.value.values }
        
        let additionalSearchValue = series.enrichments
            .filter { $0.property == .additionalSearchTerm }
            .flatMap { $0.value.values }
        
        _leadActorsArray = State(initialValue: leadActorsValue)
        _actorsArray = State(initialValue: actorsValue)
        _guestStarsArray = State(initialValue: guestStarsValue)
        _directorsArray = State(initialValue: directorsValue)
        _additionalSearchArray = State(initialValue: additionalSearchValue)
        
        _seriesViewModel = StateObject(wrappedValue: SeriesViewModel(networkManager: networkManager))
    }
    
    var body: some View {
            ZStack {
                ScrollView {
                    VStack {
                        Text("Series")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.igniteSoftPink, .igniteOrange],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        if let seriesMetadata = seriesViewModel.seriesMetadata {
                            Text((seriesMetadata.seriesTitle ?? "") + seriesMetadata.title)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.igniteWhite)
                                .padding()
                        }
                        
                        TextCompareView(
                            header: "Lead Actors",
                            storedArray: $leadActorsArray,
                            selectedIndex: $leadActorsSelectedIndex,
                            bedrockField: $seriesViewModel.leadActors,
                            height: 140,
                            first: true
                        )
                        
                        TextCompareView(
                            header: "Actors",
                            storedArray: $actorsArray,
                            selectedIndex: $actorsSelectedIndex,
                            bedrockField: $seriesViewModel.actors,
                            height: 140
                        )
                        
                        TextCompareView(
                            header: "Guest Stars",
                            storedArray: $guestStarsArray,
                            selectedIndex: $guestStarsSelectedIndex,
                            bedrockField: $seriesViewModel.guestStars,
                            height: 140
                        )
                        
                        TextCompareView(
                            header: "Directors",
                            storedArray: $directorsArray,
                            selectedIndex: $directorsSelectedIndex,
                            bedrockField: $seriesViewModel.directors,
                            height: 140
                        )
                        
                        TextCompareView(
                            header: "Additional Search",
                            storedArray: $additionalSearchArray,
                            selectedIndex: $additionalSearchSelectedIndex,
                            bedrockField: $seriesViewModel.additionalSearch,
                            height: 600
                        )
                    }
                }
                .onAppear {
                    seriesViewModel.getSeries(seriesId: series.job)
                }
                .background(.igniteBlack)
                .overlay(alignment: .bottomTrailing) {
                    VStack(spacing: 32) {
                        Button {
                            seriesViewModel.retryAndFetchSeries(
                                seriesId: series.job,
                                title: seriesViewModel.seriesMetadata?.title
                                ?? series.contentName
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
                
                if seriesViewModel.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .ignitePink))
                            .scaleEffect(2)
                        
                        Text("Loading...")
                            .foregroundStyle(.ignitePink)
                    }
                    .frame(width: 400, height: 400)
                    .background(.igniteBlack.opacity(0.8))
                }
            }
    }
}
