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
    @State private var leadActors = ""
    @State private var leadActorsSelectedIndex = 0
    
    @State private var actorsArray: [String] = []
    @State private var actors = ""
    @State private var actorsSelectedIndex = 0
    
    @State private var guestStarsArray: [String] = []
    @State private var guestStars = ""
    @State private var guestStarsSelectedIndex = 0
    
    @State private var directorsArray: [String] = []
    @State private var directors = ""
    @State private var directorsSelectedIndex = 0
    
    @State private var additionalSearchArray: [String] = []
    @State private var additionalSearch = ""
    @State private var additionalSearchSelectedIndex = 0
    
    @State private var isLoading = false
    
    
    init(series: EnrichmentJob, networkManager: NetworkManager) {
        self.series = series
        let enrichment = series.enrichments.first
        
        let leadActorsValue = enrichment?.leadActors ?? ""
        let actorsValue = enrichment?.actors ?? ""
        let guestStarsValue = enrichment?.guestStars ?? ""
        let directorsValue = enrichment?.directors ?? ""
        let additionalSearchValue = enrichment?.additionalSearchTerm ?? ""
        print("Additional search value: \(additionalSearchValue)")
        
        _leadActorsArray = State(initialValue: leadActorsValue.isEmpty ? [] : [leadActorsValue])
        _actorsArray = State(initialValue: actorsValue.isEmpty ? [] : [actorsValue])
        _guestStarsArray = State(initialValue: guestStarsValue.isEmpty ? [] : [guestStarsValue])
        _directorsArray = State(initialValue: directorsValue.isEmpty ? [] : [directorsValue])
        _additionalSearchArray = State(initialValue: additionalSearchValue.isEmpty ? [] : [additionalSearchValue])
        
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
                        
                        TextCompareView(
                            header: "Lead Actors",
                            storedArray: $leadActorsArray,
                            selectedIndex: $leadActorsSelectedIndex,
                            bedrockField: $leadActors,
                            height: 140,
                            first: true
                        )
                        
                        TextCompareView(
                            header: "Actors",
                            storedArray: $actorsArray,
                            selectedIndex: $actorsSelectedIndex,
                            bedrockField: $actors,
                            height: 140
                        )
                        
                        TextCompareView(
                            header: "Guest Stars",
                            storedArray: $guestStarsArray,
                            selectedIndex: $guestStarsSelectedIndex,
                            bedrockField: $guestStars,
                            height: 140
                        )
                        
                        TextCompareView(
                            header: "Directors",
                            storedArray: $directorsArray,
                            selectedIndex: $directorsSelectedIndex,
                            bedrockField: $directors,
                            height: 140
                        )
                        
                        TextCompareView(
                            header: "Additional Search",
                            storedArray: $additionalSearchArray,
                            selectedIndex: $additionalSearchSelectedIndex,
                            bedrockField: $additionalSearch,
                            height: 140
                        )
                        
                        if let seriesMetadata = seriesViewModel.seriesMetadata {
                            ExistingFieldsView(
                                header: "Title",
                                text: seriesMetadata.title,
                                height: 50
                            )
                            
                            ExistingFieldsView(
                                header: "Extra short synopsis",
                                text: seriesMetadata.extraShortSynopsis,
                                height: 140
                            )
                            
                            ExistingFieldsView(
                                header: "Short synopsis",
                                text: seriesMetadata.shortSynopsis,
                                height: 140
                            )
                            
                            ExistingFieldsView(
                                header: "Classification",
                                text: seriesMetadata.classification,
                                height: 50
                            )
                            
                            ExistingFieldsView(
                                header: "Background Image",
                                text: seriesMetadata.backgroundImageLogo.url,
                                height: 140
                            )
                        }
                        
                    }
                }
                .onAppear {
                    seriesViewModel.getSeries(seriesId: series.job)
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
