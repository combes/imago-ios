//
//  Photo.swift
//  Imago
//
//  Created by Christopher Combes on 8/20/26.
//

import Foundation
import UIKit
import SwiftUI

typealias Photos = [Photo]

/// Provides three types of images for display:
/// thumb - for display in photo grid
/// regular - for display upon selecting a photo thumbnail
/// small - for display in peek-pop
enum PhotoType: String, CaseIterable {
    case thumb, regular, small
}

/// Provides conformance to match server response:
/// {"total":10,"total_pages":2,"results":
///    [
///        Photo 1...n
///    ]
/// }
struct UnsplashAPIResponse: Codable {
    let total: Int
    let totalPages: Int
    let photos: Photos
    
    enum CodingKeys: String, CodingKey {
        case total
        case totalPages = "total_pages"
        case photos = "results"
    }
}

/// Provides conformance to each photo contained within
/// the JSON server response.
struct Photo: Codable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let height: Int
    let width: Int
    let description: String?
    let likes: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case height
        case width
        case `description`
        case likes
        case user
        case urls
    }
    
    struct User: Codable, Hashable {
        let name: String
        let links: Links
    }
    
    struct Links: Codable, Hashable {
        let profile: String
        
        enum CodingKeys: String, CodingKey {
            case profile = "self"
        }
    }
        
    struct Urls: Codable, Hashable {
        let thumb: String   // Grid
        let small: String   // Peek-Pop
        let regular: String // Viewing
    }
    
    let user: User
    let urls: Urls
}

extension Photo: Hashable {
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id
    }
}

extension Photo {
    func url(forType type: PhotoType) -> URL {
        let path: String
        
        switch type {
        case .thumb:
            path = urls.thumb
        case .small:
            path = urls.small
        case .regular:
            path = urls.regular
        }
        
        // Local image file paths start with "/" and not "https://".
        // Local files are used to fetch sample imagery for testing purposes.
        if path.starts(with: "/") {
            assert(path.contains("https://") == false, "Invalid local path")
            return URL(filePath: path)
        }

        // Remote image paths start with "https://".
        assert(path.contains("https://"), "Invalid remote path")
        return URL(string: path) ?? URL(filePath: "")
    }
}
// TODO: Move to separate file for organization
extension Photos {
    static let sampleData = NSDataAsset(name: "sample-data")
    
    /// Parse JSON content as `UnsplashAPIResponse`
    /// - Parameter data: data containing JSON object
    /// - Returns: [Photo]]
    static func parse(data: Data) throws -> Photos {
        let decoder = JSONDecoder()
        var photos: Photos = []
        
        let result = try decoder.decode(UnsplashAPIResponse.self, from: data)
        photos = result.photos
        
        return photos
    }
    
    /// Loads local real-world data to validate JSON parsing.
    /// - Returns: [Photo]
    static func loadRealWorldSampleData() throws -> Photos {
        guard let sampleData else {
            fatalError("No sample data")
        }
        
        return try parse(data: sampleData.data)
    }
    
    struct SampleContent {
        let height: Int
        let width: Int
        let description: String
    }
    
    /// Loads local data to support reference of bundled sample images suitable for UI testing.
    /// - Returns: [Photo]]
    static func loadSampleData() -> Photos {
        var photos: Photos = []
        func urlStringForBundleImage(id: String, type: PhotoType) -> String? {
            guard let imageURL = Bundle.main.url(forResource: "sample-image-\(id)-\(type.rawValue)", withExtension: "jpg")
            else {
                return nil
            }
            return imageURL.relativePath
        }

        func photoURLs(id: String) -> Photo.Urls {
            guard let thumbUrl = urlStringForBundleImage(id: id, type: .thumb),
                  let smallUrl = urlStringForBundleImage(id: id, type: .small),
                  let regularUrl = urlStringForBundleImage(id: id, type: .regular)
            else {
                fatalError("Could not update URLs from bundle image")
            }
            
            return Photo.Urls(thumb: thumbUrl, small: smallUrl, regular: regularUrl)
        }
        
        // Sample content is associated with "Bundle Images"
        let sampleContent: [SampleContent] = [
            SampleContent(height: 1080, width: 1350, description: "Chicago Harbor Lighthouse - Chicago, IL"),
            SampleContent(height: 1080, width: 1140, description: "Montauk Lighthouse - Long Island, NY"),
            SampleContent(height: 1080, width: 1350, description: "Highland Lighthouse - Cape Cod, MA"),
            SampleContent(height: 1080, width: 1350, description: "Portland Head Light - Portland, ME"),
            SampleContent(height: 1080, width: 1350, description: "Bass Harbor Head Light Station - Tremont, ME")
        ]
                
        // Update array of photos so we can source it for UI testing
        let user = Photo.User(name: "Christopher Combes", links: Photo.Links(profile: "https://github.com/combes"))
        for (index, object) in sampleContent.enumerated() {
            let id = "\(index + 1)" // Image count starts at 1 (e.g. sample-image-1-regular.jpg)
            let urls = photoURLs(id: id)
            let photo = Photo(id: id,
                                  createdAt: "2026-08-12T06:58:31Z",
                                  updatedAt: "2026-08-17T17:40:42Z",
                                  height: object.height,
                                  width: object.width,
                                  description: object.description,
                                  likes: Int.random(in: 0...12),
                                  user: user,
                                  urls: urls)
            
            photos.append(photo)
        }
        
        return photos
    }
    
    /// Loads invalid data with focus on bad image URLs
    /// - Returns: [Photo] with invalid data]
    static func loadInvalidImageData() -> Photos {
        var photos: Photos = []
        let invalidPath = "/invalid_local_path"
        
        for index in 0..<30 {
            let user = Photo.User(name: "Christopher Combes", links: Photo.Links(profile: "https://github.com/combes"))
            let urls = Photo.Urls(thumb: invalidPath, small: invalidPath, regular: invalidPath)
            let photo: Photo = .init(id: "\(index + 1)",
                                     createdAt: "2026-08-12T06:58:31Z",
                                     updatedAt: "2026-08-12T06:58:31Z",
                                     height: 0,
                                     width: 0,
                                     description: "This is a photo description",
                                     likes: 0,
                                     user: user,
                                     urls: urls)
            photos.append(photo)
        }
        
        return photos
    }
    
}
