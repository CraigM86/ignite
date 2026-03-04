//
//  EnrichmentListingsView.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import SwiftUI

struct EnrichmentListingsView: View {
    @State private var selectedOption: ContentFilter = .all
    @StateObject private var vm: EnrichmentListingsViewModel
    private let networkManager: NetworkManager
    
    enum ContentFilter: String, CaseIterable {
           case all = "All"
           case series = "Series"
           case episodes = "Episodes"
           
           var contentType: ContentType? {
               switch self {
               case .all:
                   return nil
               case .series:
                   return .series
               case .episodes:
                   return .episode
               }
           }
       }
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        _vm = StateObject(wrappedValue: EnrichmentListingsViewModel(networkManager: networkManager))
        
        // Customize the appearance globally
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor.orange
        UISegmentedControl.appearance().backgroundColor = UIColor.clear
        
        // Customize text colors
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.lightGray],
            for: .normal
        )
    }
    
    var filteredListings: [EnrichmentJob] {
        guard let contentType = selectedOption.contentType else {
            return vm.listings
        }
        
        return vm.listings.filter { $0.type == contentType }
    }
    
    var body: some View {
        NavigationStack {
                VStack {
                    Text("SEBn+")
                        .font(.system(size: 98, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.igniteSoftPink, .igniteOrange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    VStack {
                        HStack {
                            Spacer()
                            Picker("Options", selection: $selectedOption) {
                                ForEach(ContentFilter.allCases, id: \.self) { filter in
                                    Text(filter.rawValue)
                                        .tag(filter)
                                }
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 200)
                            .foregroundStyle(.white)
                            .padding()
                        }
                        
                        List{
                            ForEach(filteredListings, id: \.job) { listing in
                                NavigationLink(value: listing) {
                                    HStack {
                                        Text(listing.contentName)
                                            .fontWeight(.bold)
                                            .frame(width: 270, alignment: .leading)
                                        
                                        Text(listing.job)
                                            .font(.body)
                                            .frame(width: 180, alignment: .leading)
                                            .foregroundStyle(.opacity(0.5))
                                        
                                        Text(listing.type.text)
                                            .frame(width: 160, alignment: .leading)
                                            .foregroundStyle(listing.type.color)
                                        
                                        Text("Status: \(listing.status.text)")
                                            .foregroundStyle(.opacity(0.5))
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .navigationDestination(for: EnrichmentJob.self) { item in
                            switch item.type {
                            case .episode:
                                EpisodeView(episode: item, networkManager: networkManager)
                                
                            case .series:
                                SeriesView(series: item, networkManager: networkManager)
                            }
                        }
                    }
                }
                .padding(.horizontal, 48)
                .frame(maxWidth: .infinity)
                .background(.igniteBlack)
        }
        .onAppear {
            Task {
                vm.getListings()
            }
        }
    }
}
