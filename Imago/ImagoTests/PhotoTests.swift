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
    
    @Test("Test classifying an image using CoreML")
    func testImageClassification() async throws {
        let photos = Photos.loadSampleData()
        let url = await photos.last!.url(forType: .regular)
        let data = try Data(contentsOf: url)
        let ciImage = CIImage(data: data)!
        Task {
            await classifyImage(ciImage: ciImage)
        }
        
        // TODO: Need an async wait for `classifyImage` to complete its work
        try await Task.sleep(nanoseconds: 1000000000 * 3)
    }
    
    @Test("Test parsing of valid server response to ensure client processing")
    func loadRealWorldSampleData() async throws {
        try #require(Photos.sampleData != nil, "Sample data should not be nil")
        let photos = try await Photos.loadRealWorldSampleData()
        #expect(photos.count == 30, "Invalid photo count")
    }
    
    @Test("Test parsing of invalid JSON from server response")
    func parseInvalid() async throws {
        let invalidJSON = """
        {
            "total": 1,
        }
        """

        let jsonData = try #require(invalidJSON.data(using: .utf8))
        await #expect(throws: DecodingError.self) {
            _ = try await Photos.parse(data: jsonData)
        }
    }
    
    @Test("Test parsing of sample data and image file paths")
    func loadSampleData() throws {
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
    
    @Test("Test handling of invalid image paths for display in UI")
    func loadInvalidImageData() throws {
        let photos = Photos.loadInvalidImageData()
        #expect(photos.count == 30, "Invalid photo count")

        for type in PhotoType.allCases {
            let url = photos.first!.url(forType: type)
            let fileExists = FileManager.default.fileExists(atPath: url.path)
            #expect(fileExists == false , "File should NOT exist")
        }
    }
}
