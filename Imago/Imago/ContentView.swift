//
//  ContentView.swift
//  Imago
//
//  Created by Christopher Combes on 8/17/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject var provider = PhotoProvider()
    @State private var searchIsActive = false
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            Spacer()
                .navigationTitle("Imago")
            if provider.isLoading {
                ProgressView()
                    .scaleEffect(2)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
            } else {
                PhotoGrid(provider: provider)
            }
        }
        .defaultScrollAnchor(.bottom, for: .initialOffset)
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
        .defaultScrollAnchor(.top, for: .alignment)
        .searchable(text: $searchText,
                    isPresented: $searchIsActive,
                    prompt: "Look for something")
        .onSubmit(of: .search) {
            provider.fetchPhotos(searchText: searchText)
        }
        .onAppear {
            provider.fetchPhotos()
        }
    }
}

struct PhotoGrid: View {
    @StateObject var provider = PhotoProvider()
    
    var body: some View {
        ScrollView {
            if provider.error != nil {
                // TODO: Create error view
                Text("Error")
            } else if provider.photos.isEmpty {
                Text("Empty")
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 50, maximum: .infinity)),
                        GridItem(.flexible(minimum: 50, maximum: .infinity)),
                        GridItem(.flexible(minimum: 50, maximum: .infinity))
                    ],
                    alignment: .leading,
                    spacing: 10
                ) {
                    ForEach(provider.photos, id: \.self) { photo in
                        PhotoCell(imageURL: photo.url(forType: .thumb))
                    }
                }
            }
        }
    }
}

struct PhotoCell: View {
    let imageURL: URL
    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .background(Color.gray.opacity(0.1))
                
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipped()
                
            case .failure:
                Image(systemName: "photo.badge.exclamationmark")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .aspectRatio(1, contentMode: .fill)
                    .background(Color.gray.opacity(0.2))
                
            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    ContentView(provider: PhotoProvider(loadDataType: .sample(.valid)))
}

#Preview("Image Error") {
    ContentView(provider: PhotoProvider(loadDataType: .sample(.invalid)))
}

#Preview("JSON Error") {
    ContentView(provider: PhotoProvider(loadDataType: .sample(.error)))
}

#Preview("Empty") {
    ContentView(provider: PhotoProvider(loadDataType: .sample(.empty)))
}
