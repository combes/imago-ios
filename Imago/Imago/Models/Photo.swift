//
//  Photo.swift
//  Imago
//
//  Created by Christopher Combes on 8/20/26.
//

import Foundation

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
    }
    
    struct Urls: Codable {
        var raw: String
        var full: String
        var thumb: String
        var regular: String
        var small: String
    }
    
    let user: User
    let urls: Urls
}
