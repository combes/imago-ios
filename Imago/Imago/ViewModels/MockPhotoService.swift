//
//  MockPhotoService.swift
//  Imago
//
//  Created by Christopher Combes on 10/19/26.
//

import Foundation

enum SampleDataType {
    case empty
    case error
    case invalid
    case valid
}

struct MockPhotoService: PhotoService {
    private var sampleDataType: SampleDataType = .valid
    
    init(sampleDataType: SampleDataType = .valid) {
        self.sampleDataType = sampleDataType
    }

    @concurrent
    func fetch(searchText: String) async throws -> [Photo] {
        switch sampleDataType {
        case .empty:
            return []
        case .error:
            throw URLError(.badServerResponse)
        case .invalid:
            return await Photos.loadInvalidImageData()
        case .valid:
            return await Photos.loadSampleData()
        }
    }
}
