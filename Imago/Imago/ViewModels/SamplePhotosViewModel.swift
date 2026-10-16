//
//  SamplePhotosViewModel.swift
//  Imago
//
//  Created by Christopher Combes on 10/16/26.
//

import Foundation
import Observation

enum SampleDataType {
    case empty
    case error
    case invalid
    case valid
}

@Observable
final class SamplePhotosViewModel: PhotoProviding {
    var isLoading: Bool = false
    var photos: [Photo] = []
    var error: Error?
    
    private var sampleDataType: SampleDataType = .valid
    
    init(sampleDataType: SampleDataType = .valid) {
        self.sampleDataType = sampleDataType
    }

    func fetchPhotos(searchText: String) {
        switch sampleDataType {
        case .empty:
            photos = []
        case .error:
            error = URLError(.badServerResponse)
        case .invalid:
            photos = Photos.loadInvalidImageData()
        case .valid:
            photos = Photos.loadSampleData()
        }
    }
}
