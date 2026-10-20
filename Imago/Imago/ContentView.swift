//
//  ContentView.swift
//  Imago
//
//  Created by Christopher Combes on 8/17/26.
//

import SwiftUI

struct ContentView: View {
    var viewModel: PhotosViewModel
    @State var searchText: String = ""
    @State private var searchIsActive = false
    
    @Environment(\.sampleData) var isSampleData
    
    var body: some View {
        NavigationStack {
            Spacer()
                .navigationTitle("Imago")
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(2)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                Spacer()
            } else {
                PhotoGrid(viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .defaultScrollAnchor(.bottom, for: .initialOffset)
        .defaultScrollAnchor(.bottom, for: .sizeChanges)
        .defaultScrollAnchor(.top, for: .alignment)
        .searchable(text: $searchText,
                    isPresented: $searchIsActive,
                    placement: .navigationBarDrawer,
                    prompt: "Look for something")
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .onSubmit(of: .search) {
            Task {
                await viewModel.fetchPhotos(searchText: searchText)
            }
        }
        .onAppear {
            if isSampleData {
                // Show sample data immediately to support testing
                Task {
                    await viewModel.fetchPhotos(searchText: searchText)
                }
            }
        }
    }
}

struct PhotoGrid: View {
    var viewModel: PhotosViewModel
    static let gridSpacing: CGFloat = 2
    static let gridItem = GridItem(.flexible(minimum: 50,
                                             maximum: .infinity),
                                   spacing: gridSpacing,
                                   alignment: .leading)
    let layout = [ gridItem, gridItem, gridItem ]

    @State private var presentedPhotos: [Photo] = []
    @State private var presentedPhoto: Photo? {
        didSet {
            if let presentedPhoto {
                presentedPhotos = [ presentedPhoto ]
            }
        }
    }
    
    var body: some View {
        if viewModel.error != nil {
            StatusView(image: "exclamationmark.warninglight.fill",
                       color: .yellow,
                       title: "Server Error")
        } else if viewModel.photos.isEmpty {
            StatusView(image: "photo.stack",
                       color: .gray.opacity(0.5),
                       title: "Empty")
        } else {
            NavigationStack(path: $presentedPhotos) {
                ScrollView {
                    LazyVGrid(
                        columns: layout,
                        spacing: Self.gridSpacing
                    ) {
                        ForEach(viewModel.photos, id: \.self) { photo in
                            NavigationLink(value: photo) {
                                PhotoCell(photo: photo, presentedPhoto: $presentedPhotos)
                            }
                        }
                    }
                    .navigationDestination(for: Photo.self) { photo in
                        PhotoView(photo: photo)
                    }
                }
            }
        }
    }
}

struct PhotoPreview: View {
    let photo: Photo
    
    private var imageURL: URL  {
        photo.url(forType: .small)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(photo.user.name)
                .font(.callout)
                .bold()
            if !photo.description.isNilOrEmpty {
                Text(photo.description ?? "")
                    .font(.callout)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
        .padding(.top, 5)
        
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
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .gesture(TapGesture(count: 1).onEnded({ value in
                        print("tapped image")
                    }))
                
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

struct PhotoCell: View {
    let photo: Photo
    @Binding var presentedPhoto: [Photo]
    
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
                    // FIXME: Seeing "cancelled" as the reason for not loading some images from Unsplash
                    let _ = debugPrint("Failed to load image from \(imageURL.absoluteString): \(phase.error?.localizedDescription ?? "No error provided")")
                    Image(systemName: "photo.badge.exclamationmark")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .aspectRatio(1, contentMode: .fill)
                        .background(.gray.opacity(0.2))
                    
                @unknown default:
                    EmptyView()
                }
            }
            .contextMenu {
                Button("See Photo") {
                    presentedPhoto.append(photo)
                }
            } preview: {
                PhotoPreview(photo: photo)
            }
        }
    }
}

#Preview("Sample Photos") {
    @Previewable @State var searchText: String = "lighthouse"
    ContentView(viewModel: PhotosViewModel(service: MockPhotoService()), searchText: searchText)
        .environment(\.sampleData, true)
}

#Preview("Image Error") {
    @Previewable @State var searchText: String = "lighthouse"
    ContentView(viewModel: PhotosViewModel(service: MockPhotoService(sampleDataType: .invalid)), searchText: searchText)
        .environment(\.sampleData, true)
}

#Preview("JSON Error") {
    @Previewable @State var searchText: String = "lighthouse"
    ContentView(viewModel: PhotosViewModel(service: MockPhotoService(sampleDataType: .error)), searchText: searchText)
        .environment(\.sampleData, true)
}

#Preview("Empty") {
    @Previewable @State var searchText: String = "lighthouse"
    ContentView(viewModel: PhotosViewModel(service: MockPhotoService(sampleDataType: .empty)), searchText: searchText)
        .environment(\.sampleData, true)
}
