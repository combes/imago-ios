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

struct Photo: Codable {
    var id: String
    var createdAt: String
    var updatedAt: String
    var height: Int
    var width: Int
    var description: String?
    var likes: Int
    
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
    
    struct User: Codable {
        var name: String
        var links: Links
    }
    
    struct Links: Codable {
        var profile: String
        
        enum CodingKeys: String, CodingKey {
            case profile = "self"
        }
    }
    
    enum PhotoType: String {
        case thumb, regular, small
    }
    
    struct Urls: Codable {
        var thumb: String   // Grid
        var regular: String // Viewing
        var small: String   // Peek-Pop
    }
    
    var user: User
    var urls: Urls
}

extension Photo {
    func url(forType type: PhotoType) -> URL {
        switch type {
        case .thumb:
            return URL(filePath: urls.thumb)
        case .regular:
            return URL(filePath: urls.regular)
        case .small:
            return URL(filePath: urls.small)
        }
    }
    
    func urlStringForBundleImage(id: Int, size: String) -> String? {
        guard let imageURL = Bundle.main.url(forResource: "sample-image-\(id)-\(size)", withExtension: "jpg")
        else {
            return nil
        }
        return imageURL.relativePath
    }
    
    mutating func revise(id: Int, height: Int, width: Int, description: String) {
        self.id = "\(id)"
        self.height = height
        self.width = width
        self.likes = Int.random(in: 0...12)
        self.description = description
        
        // FIXME: Sample images should only be included for previews and unit testing - not copied for deployment.
        // Update each photo type with derived local URL path (e.g. "file://<path>")
        func updatePhoto(type: PhotoType, id: Int) {
            guard let url = urlStringForBundleImage(id: id, size: type.rawValue)
            else {
                fatalError("Failed to load image for id: \(id), size: \(type.rawValue)")
            }
            switch type {
            case .thumb:
                self.urls.thumb = url
            case .regular:
                self.urls.regular = url
            case .small:
                self.urls.small = url
            }
        }
        
        updatePhoto(type: .regular, id: id)
        updatePhoto(type: .small, id: id)
        updatePhoto(type: .thumb, id: id)
        
        // Update owner of photos in user content
        user.name = "Christopher Combes"
        user.links.profile = "https://example.com"
    }
}

extension Photos {
    static let sampleData = NSDataAsset(name: "sample-data")
    
    /// Loads real-world JSON data to validate parsing.
    /// - Returns: [Photo]
    static func loadRealWorldSampleData() -> Photos {
        guard let sampleData else {
            fatalError("No sample data")
        }

        let decoder = JSONDecoder()
        var photos: Photos = []
        do {
            photos = try decoder.decode(Photos.self, from: sampleData.data)
        } catch {
            debugPrint("Error decoding sample data: \(error.localizedDescription)")
        }
        return photos
    }
    
    struct SampleContent {
        let height: Int
        let width: Int
        let description: String
    }
    
    static func loadSampleData() -> Photos {
        var photos: Photos = []
        
        // Load a pre-populated photo so we can source it for sample data creation.
        let samplePhotos = Photos.loadRealWorldSampleData()
        guard var photo = samplePhotos.first else {
            fatalError("Could not find first photo")
        }
        
        // FIXME: Although this code is working, it would be simpler to create the `Photo` objects directly.
        
        // Sample content is associated with "Bundle Images"
        let sampleContent: [SampleContent] = [
            SampleContent(height: 1080, width: 1350, description: "Chicago Harbor Lighthouse - Chicago, IL"),
            SampleContent(height: 1080, width: 1140, description: "Montauk Lighthouse - Long Island, NY"),
            SampleContent(height: 1080, width: 1350, description: "Highland Lighthouse - Cape Cod, MA"),
            SampleContent(height: 1080, width: 1350, description: "Portland Head Light - Portland, ME"),
            SampleContent(height: 1080, width: 1350, description: "Bass Harbor Head Light Station - Tremont, ME")
        ]
                
        // Update array of photos so we can source it for UI testing
        for (index, object) in sampleContent.enumerated() {
            let id = index + 1 // Image count starts at 1 (e.g. sample-image-1-regular.jpg)
            photo.revise(id: id, height: object.height, width: object.width, description: object.description)
            photos.append(photo)
        }
        
        return photos
    }    
}
