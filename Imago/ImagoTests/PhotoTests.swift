//
//  PhotoTests.swift
//  ImagoTests
//
//  Created by Christopher Combes on 9/16/26.
//

import Testing
@testable import Imago
import UIKit

struct PhotoTests {
    
    @Test func testSampleDataImport() async throws {
        try #require(Photos.sampleData != nil, "Sample data should not be nil")
        let photos = Photos.loadRealWorldSampleData()
        #expect(photos.count == 30, "Invalid photo count")
    }
    
    @Test func testLoadSampleData() throws {
        let photos = Photos.loadSampleData()
        #expect(photos.count == 5, "Invalid photo count")
        #expect(photos.first?.id == "1")
        #expect(photos.last?.id == "5")
    
        for type in PhotoType.allCases {
            let url = photos.first!.url(forType: type)
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            #expect(fileExists == true , "File should exist")
        }
    }
    
    @Test func testLoadInvalidImageData() throws {
        let photos = Photos.loadInvalidImageData()
        #expect(photos.count == 30, "Invalid photo count")

        for type in PhotoType.allCases {
            let url = photos.first!.url(forType: type)
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            #expect(fileExists == false , "File should NOT exist")
        }
    }
}
