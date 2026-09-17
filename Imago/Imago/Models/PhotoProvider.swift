//
//  PhotoProvider.swift
//  Imago
//
//  Created by Christopher Combes on 8/28/26.
//

import Combine

class PhotoProvider: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var photos: [Photo] = []
    private var searchTerm = ""
    private var isSampleData = false
    
    init(searchTerm: String = "", loadSampleData: Bool = false) {
        self.searchTerm = searchTerm
        isSampleData = loadSampleData
    }
    
    func fetchPhotos() {
        isLoading = true

        Task {
            defer {
                isLoading = false
            }
            guard !isSampleData
            else {
                photos = .loadSampleData()
                return
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
