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
        #expect(throws: UnsplashAccessKeyError.replace) {
            let key = try UnsplashAccessKey.loadAccessKey()
            #expect(key != nil)
        }
    }
}
