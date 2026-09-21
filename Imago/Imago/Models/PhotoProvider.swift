//
//  PhotoProvider.swift
//  Imago
//
//  Created by Christopher Combes on 8/28/26.
//

import Combine
import Foundation

enum LoadDataType {
    enum SampleDataType {
        case empty
        case error
        case invalid
        case valid
    }
    case sample(SampleDataType)
    case live
}

class PhotoProvider: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var photos: [Photo] = []
    @Published var error: Error?
    private var loadDataType: LoadDataType = .live

    init(loadDataType: LoadDataType = .live) {
        self.loadDataType = loadDataType
    }
    
    func fetchPhotos(searchText: String = "") {
        guard !isLoading else { return }
        // TODO: Add task cancel
        isLoading = true

        func fetchSampleData(type: LoadDataType.SampleDataType) -> [Photo] {
            switch type {
            case .empty:
                return []
            case .error:
                error = URLError(.badServerResponse)
            case .invalid:
                return Photos.loadInvalidImageData()
            case .valid:
                return Photos.loadSampleData()
            }
            
            return []
        }
        
        func fetchLiveData() -> [Photo] {
            []
        }
        
        Task {
            defer {
                isLoading = false
            }
            switch loadDataType {
            case .sample(let type):
                photos = fetchSampleData(type: type)
            case .live:
                photos = fetchLiveData()
            }
        }
        
        /*
         TODO: Load JSON from server
         var urlComponents = URLComponents(string: "https://todo/get")!
         
         // Define the parameters.
         let parameters: [String: String] = [
         "key": "value",
         "key": "value"
         ]
         
         // Add the query parameters to the URL.
         urlComponents.queryItems = parameters.map { key, value in
         URLQueryItem(name: key, value: value)
         }
         
         // Ensure we have a valid URL and throw a URLError if it fails.
         guard let url = urlComponents.url else {
             throw URLError(.badURL)
         }

         // Use URLSession to fetch the data asynchronously.
         let (data, response) = try await URLSession.shared.data(from: url)
         */
    }
}
