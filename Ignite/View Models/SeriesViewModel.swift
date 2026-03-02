//
//  SeriesViewModel.swift
//  Ignite
//
//  Created by Craig Martin on 2/3/2026.
//

import Combine
import Foundation

class SeriesViewModel: ObservableObject {
    @Published var seriesMetadata: ExistingMetadata? = nil
    
    let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func getSeries(seriesId: String)  {
        Task {
            seriesMetadata = try await networkManager.fetchSeriesMetaData(seriesId: seriesId)
        }
    }
}
