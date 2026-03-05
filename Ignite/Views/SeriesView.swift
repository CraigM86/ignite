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
    
    @State private var leadActorsArray: [String] = []
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
                            enrichment: $seriesViewModel.leadActorsEnrichment,
                            height: 220,
                            first: true
                        )
                        
                        TextCompareView(
                            header: "Actors",
                            storedArray: $actorsArray,
                            selectedIndex: $actorsSelectedIndex,
                            bedrockField: $seriesViewModel.actors,
                            enrichment: $seriesViewModel.actorsEnrichment,
                            height: 220
                        )
                        
                        TextCompareView(
                            header: "Guest Stars",
                            storedArray: $guestStarsArray,
                            selectedIndex: $guestStarsSelectedIndex,
                            bedrockField: $seriesViewModel.guestStars,
                            enrichment: $seriesViewModel.guestStarsEnrichment,
                            height: 220
                        )
                        
                        TextCompareView(
                            header: "Directors",
                            storedArray: $directorsArray,
                            selectedIndex: $directorsSelectedIndex,
                            bedrockField: $seriesViewModel.directors,
                            enrichment: $seriesViewModel.directorsEnrichment,
                            height: 220
                        )
                        
                        TextCompareView(
                            header: "Additional Search",
                            storedArray: $additionalSearchArray,
                            selectedIndex: $additionalSearchSelectedIndex,
                            bedrockField: $seriesViewModel.additionalSearch,
                            enrichment: $seriesViewModel.additionalSearchEnrichment,
                            height: 800
                        )
                        
                        HStack {
                            
                            VStack(alignment: .leading) {
                                Text("Validation Agent")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding(.bottom)
                                
                                Text("Confidence score: \(String(format: "%.2f", seriesViewModel.validator?.confidenceScore ?? 0.0))")
                                    .font(.title3)
                                    .padding(.bottom)
                                
                                
                                Text("Source: \(seriesViewModel.validator?.source ?? "Unknown")")
                                    .font(.title3)
                                    .padding(.bottom)
                                
                                Text("Inconsistencies")
                                    .font(.title3)
                                    .padding(.bottom)
                                
                                if let inconsistencies = seriesViewModel.validator?.inconsistencies {
                                    ForEach(inconsistencies, id: \.self) { inconsistency in
                                        Text(inconsistency)
                                    }
                                }
                            }
                            .padding(.horizontal, 48)
                            .padding(.vertical, 24)
                            
                            Spacer()
                        }
                    }
                }
                .onAppear {
                    setupAIFields()
                    seriesViewModel.getSeries(seriesId: series.job)
                }
                .onChange(of: seriesViewModel.seriesMetadata) { metadata in
                    if let metadata {
                        print("Metadata")
                        leadActorsArray.append(metadata.leadActors ?? "")
                        actorsArray.append(metadata.actors ?? "")
                        guestStarsArray.append(metadata.guestStars ?? "")
                        directorsArray.append(metadata.directors ?? "")
                    }
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
                            seriesViewModel.approveJob(
                                seriesId: series.job,
                                leadActors: leadActorsArray[leadActorsSelectedIndex],
                                actors: actorsArray[actorsSelectedIndex],
                                guestStars: guestStarsArray[guestStarsSelectedIndex],
                                directors: directorsArray[directorsSelectedIndex],
                                additionalSearch: additionalSearchArray[additionalSearchSelectedIndex]
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
                
                if seriesViewModel.isLoading {
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
                
                if let success = seriesViewModel.approvalSuccess {
                    if success {
                        Text("Approval succeeded!")
                            .foregroundColor(.green)
                            .padding()
                    } else {
                        Text("Approval failed: \(seriesViewModel.approvalErrorMessage ?? "Unknown error")")
                            .foregroundColor(.red)
                            .padding()
                    }
                }
            }
    }
    
    private func setupAIFields() {
        let leadActorsValue = series.enrichments
            .first { $0.property == .leadActors }
            .map { $0.value.joined }
        
        let actorsValue = series.enrichments
            .first { $0.property == .actors }
            .map { $0.value.joined }
        
        let guestStarsValue = series.enrichments
            .first { $0.property == .guestStars }
            .map { $0.value.joined }
        
        let directorsValue = series.enrichments
            .first { $0.property == .directors }
            .map { $0.value.joined }
        
        let additionalSearchValue = series.enrichments
            .first { $0.property == .additionalSearchTerm }
            .map { $0.value.joined }
        
        seriesViewModel.leadActors = leadActorsValue ?? ""
        seriesViewModel.actors = actorsValue ?? ""
        seriesViewModel.guestStars = guestStarsValue ?? ""
        seriesViewModel.directors = directorsValue ?? ""
        seriesViewModel.additionalSearch = additionalSearchValue ?? ""
    }
}
