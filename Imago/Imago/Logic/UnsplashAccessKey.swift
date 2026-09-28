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
    case replace
    
    var description: String {
        switch self {
        case .missing:
            "Unable to locate client-key file"
        case .unreadable:
            "Unable to read client-key file"
        case .replace:
            "Please replace the placeholder key in file client-key"
        }
    }
}

struct UnsplashAccessKey {
    static let replaceKey = "REPLACE_WITH_UNPLASH_ACCESS_KEY"
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
        
        guard let fileURL = Bundle.main.url(forResource: "client-key", withExtension: nil)
        else {
            throw UnsplashAccessKeyError.missing
        }
        guard let fileContents = try? String(contentsOf: fileURL, encoding: .utf8)
        else {
            throw UnsplashAccessKeyError.unreadable
        }

        accessKey = fileContents.trimmingCharacters(in: .whitespacesAndNewlines)

        guard accessKey != replaceKey
        else {
            throw UnsplashAccessKeyError.replace
        }
        
        return accessKey
    }
}
