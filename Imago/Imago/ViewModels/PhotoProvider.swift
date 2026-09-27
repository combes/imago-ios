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
    private var loadDataType: LoadDataType = .live

    init(loadDataType: LoadDataType = .live) {
        self.loadDataType = loadDataType
    }
    
    func fetchPhotos(searchText: String = "") {
        guard !isLoading else { return }
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
            
            var urlComponents = URLComponents(string: "https://api.unsplash.com/search/photos")!
            // It is not documented in the API https://unsplash.com/documentation#search-photos
            // However, on testing of the web interface it appears hyphens are used in place of spaces.
            // let escapedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
            let escapedText = searchText.components(separatedBy: .whitespaces).joined(separator: "-")
            
            // Define the query parameters
            let parameters: [String: String] = [
            "client_id": "TODO:",
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
            
            return try Photos.parse(data: data)
        }
        
        Task { [weak self] in
            defer {
                self?.isLoading = false
            }
            
            do {
                let dataType = self?.loadDataType ?? .sample(.empty)
                switch dataType {
                case .sample(let type):
                    self?.photos = try fetchSampleData(type: type)
                case .live:
                    self?.photos = try await fetchLiveData()
                }
            } catch {
                self?.error = error
            }
        }
    }
}
