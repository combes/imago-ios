//
//  UnsplashAccessKeyTest.swift
//  ImagoTests
//
//  Created by Christopher Combes on 9/27/26.
//

import Testing
@testable import Imago

struct UnsplashAccessKeyTest {
    
    @Test func loadAccessKey() throws {
        do {
            let key = try UnsplashAccessKey.loadAccessKey()
            #expect(key != nil)
        } catch let error as UnsplashAccessKeyError {
            switch error {
            case .missing, .unreadable:
                fatalError(error.description)
            case .replace:
                // Test should pass but user must replace key for server access
                break
            }
        }
    }
}
