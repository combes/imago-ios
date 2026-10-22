//
//  PhotoListView.swift
//  Imago
//
//  Created by Christopher Combes on 10/21/26.
//

import SwiftUI

struct PhotoListView: View {
    var photos: [Photo] = []    
    @State var currentIndex: Int = 0
    
    var body: some View {
        VStack{
            TabView(selection: $currentIndex) {
                ForEach(0 ..< photos.count, id: \.self) { i in
                    VStack{
                        PhotoView(photo: photos[i])
                    }
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
    }
}

#Preview("Sample Photo List") {
    let photos = Photos.loadSampleData()
    PhotoListView(photos: photos, currentIndex: 0)
        .environment(\.sampleData, true)
}
