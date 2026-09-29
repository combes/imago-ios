//
//  UnsplashAccessKeyTest.swift
//  ImagoTests
//
//  Created by Christopher Combes on 9/27/26.
//

import Testing
@testable import Imago

struct UnsplashAccessKeyTest {
    
    @Test("Verify client-key is present in bundle") func loadAccessKey() throws {
        _ = try UnsplashAccessKey.loadAccessKey()
    }
}
