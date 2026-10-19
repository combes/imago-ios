//
//  PhotosViewModel.swift
//  Imago
//
//  Created by Christopher Combes on 10/16/26.
//

import Foundation
import Observation

@Observable
final class PhotosViewModel: PhotoProviding {
    var isLoading: Bool = false
    var photos: [Photo] = []
    var error: Error?
    private let accessKey: String = {
        do {
            return try UnsplashAccessKey.loadAccessKey() ?? ""
        } catch {
            fatalError("Invalid access key")
        }
        return ""
    }()
    
    func fetchPhotos(searchText: String) {
        guard searchText.isEmpty == false else {
            return
        }
        
        Task {
            isLoading = true
            do {
                photos = try await fetchLiveData(searchText: searchText)
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
    
    @concurrent
    private func fetchLiveData(searchText: String) async throws -> [Photo] {
        var urlComponents = URLComponents(string: "https://api.unsplash.com/search/photos")!
        // It is not documented in the API https://unsplash.com/documentation#search-photos
        // However, on testing of the web interface it appears hyphens are used in place of spaces.
        // let escapedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let escapedText = searchText.components(separatedBy: .whitespaces).joined(separator: "-")
        
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
        
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
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
        
        #if DEBUG
        if let cacheControl = httpResponse.allHeaderFields["Cache-Control"] as? String {
            // e.g. public,max-age=86400,stale-if-error=3600,stale-while-revalidate=60
            print(cacheControl)
        }
        #endif
        
        return try await Photos.parse(data: data)
    }
}
