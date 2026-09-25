//
//  Photo+SampleData.swift
//  Imago
//
//  Created by Christopher Combes on 9/25/26.
//

import Foundation
import UIKit
import SwiftUI

extension Photos {
    static let sampleData = NSDataAsset(name: "sample-data")
    
    /// Loads local real-world data to validate JSON parsing.
    /// - Returns: [Photo]
    static func loadRealWorldSampleData() throws -> Photos {
        guard let sampleData else {
            fatalError("No sample data")
        }
        
        return try Photos.parse(data: sampleData.data)
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
