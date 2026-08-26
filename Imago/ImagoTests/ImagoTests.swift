//
//  ImagoTests.swift
//  ImagoTests
//
//  Created by Christopher Combes on 8/17/26.
//

import XCTest
@testable import Imago

final class ImagoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSampleDataImport() throws {        
        let asset = try XCTUnwrap(Photos.sampleData, "Could not load sample data asset")

        do {
            let decoder = JSONDecoder()
            let photos = try decoder.decode(Photos.self, from: asset.data)
            photos.forEach { photo in
                print("Loaded photo id \(photo.id)")
            }
        } catch {
            print(error)
        }
    }
}
