//
//  ImagoApp.swift
//  Imago
//
//  Created by Christopher Combes on 8/17/26.
//

import Observation
import SwiftUI

extension EnvironmentValues {
    @Entry var sampleData = false
}

@main
struct ImagoApp: App {
    var body: some Scene {
        WindowGroup {
            // If we are running unit tests, load an empty view instead
            if NSClassFromString("XCTestCase") != nil {
                Text("Running Tests...")
            } else if ProcessInfo.processInfo.arguments.contains("--sampleData") {
                ContentView(viewModel: PhotosViewModel(service: MockPhotoService()))
                    .environment(\.sampleData, true)
            } else {
                ContentView(viewModel: PhotosViewModel())
            }
        }
    }
}
