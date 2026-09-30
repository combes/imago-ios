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
            case profile = "html"
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

extension Photos {
    
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
}
