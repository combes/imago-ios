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
            ContentView(provider: PhotoProvider())
        }
    }
}
