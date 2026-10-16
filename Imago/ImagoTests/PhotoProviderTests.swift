//
//  PhotoProviderTests.swift
//  ImagoTests
//
//  Created by Christopher Combes on 10/14/26.
//

import Observation
import Testing
@testable import Imago

struct PhotoProviderTests {

    @Test func fetchPhotos()  throws {
        let viewModel = SamplePhotosViewModel()
        viewModel.fetchPhotos(searchText: "")
        
        viewModel.fetchPhotos(searchText: "")
        #expect(viewModel.photos.count > 0)
    }

}
