//
//  PhotoProvider.swift
//  Imago
//
//  Created by Christopher Combes on 8/28/26.
//

import Foundation
import Observation

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

@Observable
final class PhotoProvider {
    var isLoading: Bool = false
    var photos: [Photo] = []
    var error: Error?
    
    private class DataObject {
        let data: Data
        init(data: Data) {
            self.data = data
        }
    }
    
    @ObservationIgnored
    private var cache: NSCache<NSString, DataObject> = .init()
    private var loadDataType: LoadDataType = .live
    
    init(loadDataType: LoadDataType = .live) {
        self.loadDataType = loadDataType
    }
    
    func fetchPhotos(searchText: String = "") {
        isLoading = true
        
        func fetchSampleData(type: LoadDataType.SampleDataType) throws -> [Photo] {
            switch type {
            case .empty:
                break
            case .error:
                throw URLError(.badServerResponse)
            case .invalid:
                return Photos.loadInvalidImageData()
            case .valid:
                return Photos.loadSampleData()
            }
            
            return []
        }
        
        func fetchLiveData() async throws -> [Photo] {
            guard searchText.isEmpty == false else {
                return []
            }
            
            // Check cache first to avoid server call
            if let data = cache.object(forKey: searchText as NSString) {
                return try Photos.parse(data: data.data)
            }
            
            var urlComponents = URLComponents(string: "https://api.unsplash.com/search/photos")!
            // It is not documented in the API https://unsplash.com/documentation#search-photos
            // However, on testing of the web interface it appears hyphens are used in place of spaces.
            // let escapedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            let escapedText = searchText.components(separatedBy: .whitespaces).joined(separator: "-")
            
            let accessKey = try UnsplashAccessKey.loadAccessKey() ?? ""
            
            // Define the query parameters
            let parameters: [String: String] = [
                "client_id": accessKey,
                "page": "1",
                "per_page": "30",
                "query": escapedText
            ]
            
            // Add the query parameters to the URL
            urlComponents.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
            
            // Ensure we have a valid URL and throw a URLError if it fails
            guard let url = urlComponents.url else {
                throw URLError(.badURL)
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let (data, response) = try await URLSession.shared.data(for: request)
            assert(response as? HTTPURLResponse != nil , "Response is not HTTPURLResponse")
            
            guard let httpResponse = response as? HTTPURLResponse
            else
            {
                throw URLError(.badServerResponse)
            }
            
            // See https://unsplash.com/documentation#error-messages
            switch httpResponse.statusCode {
            case 200: break
            case 400: throw URLError(.badURL)
            case 401: throw URLError(.userAuthenticationRequired)
            case 403: throw URLError(.userAuthenticationRequired)
            case 404: throw URLError(.resourceUnavailable)
            default: throw URLError(.unknown)
            }
            
            // Store data in memory-based cache
            cache.setObject(
                .init(data: data),
                forKey: searchText as NSString,
                cost: data.count
            )
            
            return try Photos.parse(data: data)
        }
        
        Task {
            defer {
                isLoading = false
            }
            
            do {
                let dataType = loadDataType
                switch dataType {
                case .sample(let type):
                    photos = try fetchSampleData(type: type)
                case .live:
                    photos = try await fetchLiveData()
                }
            } catch let fetchError {
                error = fetchError
            }
        }
    }
}
