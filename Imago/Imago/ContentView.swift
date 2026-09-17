//
//  ContentView.swift
//  Imago
//
//  Created by Christopher Combes on 8/17/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var provider = PhotoProvider()
    let imageURL = Photos.loadSampleData().first!.url(forType: .thumb)

    var body: some View {
        if provider.isLoading {
            ProgressView()
                .scaleEffect(2)
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fill)
                .onAppear {
                    provider.fetchPhotos()
                }
        } else {
            PhotoGrid(provider: provider)
        }
    }
}

struct PhotoGrid: View {
    @StateObject var provider = PhotoProvider()
    let imageURL = Photos.loadSampleData().first!.url(forType: .thumb)

    var body: some View {
        ScrollView {
            // TODO: Fetch JSON data asynchronously - sample or real-world
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    // Placeholder view while loading
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .background(Color.gray.opacity(0.1))
                        
                case .success(let image):
                    // Rendered image styled to a perfect square crop
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipped()
                        
                case .failure:
                    // Fallback view if image download fails
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .background(Color.gray.opacity(0.2))
                        
                @unknown default:
                    EmptyView()
                }
            }
            LazyVGrid(
                columns: [
                    GridItem(.flexible(minimum: 50, maximum: .infinity)),
                    GridItem(.flexible(minimum: 50, maximum: .infinity)),
                    GridItem(.flexible(minimum: 50, maximum: .infinity))
                ],
                alignment: .leading,
                spacing: 10
            ) {
                ForEach(0..<30, id: \.self) { box in
                    Text("\(box)")
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .border(Color.gray)
                }
            }.padding()
        }
    }
}

#Preview {
    ContentView(provider: PhotoProvider(loadSampleData: true))
}
