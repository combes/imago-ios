//
//  ContentView.swift
//  Imago
//
//  Created by Christopher Combes on 8/17/26.
//

import SwiftUI

struct ContentView: View {
    var provider = PhotoProvider()
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
                Spacer()
            } else {
                PhotoGrid(provider: provider)
            }
        }
        .defaultScrollAnchor(.bottom, for: .initialOffset)
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
        .defaultScrollAnchor(.top, for: .alignment)
        .searchable(text: $searchText,
                    isPresented: $searchIsActive,
                    placement: .navigationBarDrawer,
                    prompt: "Look for something")
        .onSubmit(of: .search) {
            provider.fetchPhotos(searchText: searchText)
        }
        .onAppear {
            provider.fetchPhotos()
        }
    }
}

struct StatusView: View {
    let image: String
    let color: Color
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: image)
                .font(.system(size: 100))
                .foregroundStyle(color)
            Text(title)
                .font(.largeTitle)
                .padding(2)
                .foregroundStyle(color)
            Spacer()
        }
        .padding(.top, 64)
    }
}

struct PhotoGrid: View {
    var provider = PhotoProvider()
    static let gridSpacing: CGFloat = 2
    static let gridItem = GridItem(.flexible(minimum: 50,
                                             maximum: .infinity),
                                   spacing: gridSpacing,
                                   alignment: .leading)
    let layout = [ gridItem, gridItem, gridItem ]
    
    var body: some View {
        if provider.error != nil {
            StatusView(image: "exclamationmark.warninglight.fill",
                       color: .yellow,
                       title: "Server Error")
        } else if provider.photos.isEmpty {
            StatusView(image: "photo.stack",
                       color: .gray.opacity(0.5),
                       title: "Empty")
        } else {
            ScrollView {
                LazyVGrid(
                    columns: layout,
                    spacing: Self.gridSpacing
                ) {
                    ForEach(provider.photos, id: \.self) { photo in
                        PhotoCell(photo: photo)
                    }
                }
            }
        }
    }
}

struct PhotoCell: View {
    let photo: Photo
    private var imageURL: URL  {
        photo.url(forType: .thumb)
    }
    
    var body: some View {
        NavigationLink {
            PhotoView(photo: photo)
        } label: {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .background(.gray.opacity(0.2))
                    
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
                        .background(.gray.opacity(0.2))
                    
                @unknown default:
                    EmptyView()
                }
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
