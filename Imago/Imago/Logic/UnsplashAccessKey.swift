//
//  UnsplashAccessKey.swift
//  Imago
//
//  Created by Christopher Combes on 9/27/26.
//

import Foundation

enum UnsplashAccessKeyError: Error, CustomStringConvertible {
    case missing
    case unreadable
    
    var description: String {
        switch self {
        case .missing:
            "Unable to locate \(UnsplashAccessKey.accessKeyName) file"
        case .unreadable:
            "Unable to read \(UnsplashAccessKey.accessKeyName) file"
        }
    }
}

struct UnsplashAccessKey {
    static let accessKeyName = "access-key"
    static var accessKey: String?
    
    /// Loads Unsplash access key from bundled resource file.
    ///
    /// Storing an API key in a plain text file is not secure.  However, the access key is used only for Public Authentication.
    /// User Authentication requires an authentication flow using the "secret key" provided when registering for API access.
    ///
    /// See [Unsplash Documentation](https://unsplash.com/documentation#public-authentication) for details.
    /// - Returns: The Unsplash client access key or `nil` if one cannot be found.
    static func loadAccessKey() throws -> String? {
        guard accessKey == nil else { return accessKey }
        
        guard let fileURL = Bundle.main.url(forResource: accessKeyName, withExtension: nil)
        else {
            throw UnsplashAccessKeyError.missing
        }
        guard let fileContents = try? String(contentsOf: fileURL, encoding: .utf8)
        else {
            throw UnsplashAccessKeyError.unreadable
        }

        accessKey = fileContents.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return accessKey
    }
}
