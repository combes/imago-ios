//
//  ImagoApp.swift
//  Imago
//
//  Created by Christopher Combes on 8/17/26.
//

import SwiftUI

@main
struct ImagoApp: App {
    var body: some Scene {
        WindowGroup {
            // If we are running unit tests, load an empty view instead
            if NSClassFromString("XCTestCase") != nil {
                Text("Running Tests...")
            } else {
                ContentView()
            }
        }
    }
}
