//
//  PhotoViewModelTests.swift
//  ImagoTests
//
//  Created by Christopher Combes on 10/19/26.
//

import Dispatch
import Observation
import Testing
@testable import Imago

struct PhotoViewModelTests {

    @MainActor
    @Test func fetchPhotos() async throws {
        let viewModel = PhotosViewModel(service: MockPhotoService())
  
        await viewModel.fetchPhotos(searchText: "")
        #expect(viewModel.photos.count == 0)
        
        await viewModel.fetchPhotos(searchText: "lighthouse") // any text will allow search to continue
        #expect(viewModel.photos.count == 5)
    }

}
