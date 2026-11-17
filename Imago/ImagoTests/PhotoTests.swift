//
//  PhotoTests.swift
//  ImagoTests
//
//  Created by Christopher Combes on 9/16/26.
//

@preconcurrency import Vision
import CoreML
import Testing
@testable import Imago
import UIKit

// MARK: Helper Methods

private func getSampleImage() throws -> CGImage {
    let photos = Photos.loadSampleData()
    let photo = try #require(photos.first)
    let url =  photo.url(forType: .regular)
    let data = try Data(contentsOf: url)
    let image = try #require(UIImage(data: data))
    let cgImage = try #require(image.cgImage)
    return cgImage
}

@MainActor
private func runClassificationTest(using classifier: Classifier, expectedClassification: ClassificationResult, classificationError: ClassificationError? = nil) async throws {
    let cgImage = try getSampleImage()
    let imageClassifier = ImageClassifier(classifier: classifier)

    await confirmation("Image confirmation test") { confirm in
        let _: Void = await withCheckedContinuation { continuation in
             imageClassifier.classifyImage(cgImage: cgImage) { result in
                 switch result {
                 case .failure(let error):
                     #expect(classificationError == error)
                 case .success(let classification):
                     #expect(expectedClassification == classification)
                 }
                confirm()
                continuation.resume()
            }
        }
    }
}

// MARK: Tests

struct PhotoTests {
    
    @MainActor
    @Test("Test classifying an image using CoreML")
    func testImageClassification() async throws {
        let classification = ClassificationResult(classifications: ["beacon", "lighthouse"], percent: 52.27701)
        try await runClassificationTest(using: .default, expectedClassification: classification)
    }
    
    @MainActor
    @Test("Test classifying an invalid image using CoreML")
    func testInvalidImageClassification() async throws {
        let classification = ClassificationResult(classifications: [], percent: 0)
        try await runClassificationTest(using: .failing, expectedClassification: classification, classificationError: .failed)
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
