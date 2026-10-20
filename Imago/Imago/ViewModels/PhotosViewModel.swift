//
//  PhotosViewModel.swift
//  Imago
//
//  Created by Christopher Combes on 10/16/26.
//

import Foundation
import Observation

@Observable
final class PhotosViewModel {
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
    private let service: PhotoService
    
    init(service: PhotoService = DefaultPhotoService()) {
        self.service = service
    }
    
    func fetchPhotos(searchText: String) async {
        guard searchText.isEmpty == false else {
            return
        }

        isLoading = true
        do {
            photos = try await service.fetch(searchText: searchText)
        } catch {
            self.error = error
        }
        isLoading = false
    }
}
