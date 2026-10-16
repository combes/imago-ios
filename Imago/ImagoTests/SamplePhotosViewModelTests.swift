//
//  SamplePhotosViewModelTests.swift
//  ImagoTests
//
//  Created by Christopher Combes on 10/16/26.
//

import Testing
@testable import Imago

struct SamplePhotosViewModelTests {

    @Test func fetchPhotos() throws {
        let viewModel = SamplePhotosViewModel()
        viewModel.fetchPhotos(searchText: "")
        #expect(viewModel.photos.count > 0)
    }

}
