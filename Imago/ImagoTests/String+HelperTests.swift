//
//  String+HelperTests.swift
//  ImagoTests
//
//  Created by Christopher Combes on 9/30/26.
//

import Testing
@testable import Imago

struct String_HelperTests {

    @Test func isNilOrEmpty() async throws {
        var text: String? = nil
        #expect(text.isNilOrEmpty)
        text = ""
        #expect(text.isNilOrEmpty)
        text = "Hello"
        #expect(!text.isNilOrEmpty)
    }

}
