//
//  PhotoView.swift
//  Imago
//
//  Created by Christopher Combes on 9/22/26.
//

import SwiftUI

struct PhotoView: View {
    let photo: Photo
    private var imageURL: URL  {
        photo.url(forType: .regular)
    }
    
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    var body: some View {
        // TODO: Resolve code duplication with code in ContentView
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .background(.gray.opacity(0.1))
                
            case .success(let image):
                image
                    .resizable()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .scaleEffect(currentZoom + totalZoom)
                    .gesture(
                        MagnifyGesture()
                            .onChanged { value in
                                currentZoom = value.magnification - 1
                            }
                            .onEnded { value in
                                totalZoom += currentZoom
                                currentZoom = 0
                            }
                    )
                    .accessibilityZoomAction { action in
                        // Allow assistive technologies to control the zoom level
                        if action.direction == .zoomIn {
                            totalZoom += 1
                        } else {
                            totalZoom -= 1
                        }
                    }
                
            case .failure:
                Image(systemName: "photo.badge.exclamationmark")
                    .foregroundColor(.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .background(Color.gray.opacity(0.2))
                
            @unknown default:
                EmptyView()
            }
        }
        Spacer()
        VStack(alignment: .leading, spacing: 10) {
            Link(photo.user.name, destination: URL(string: photo.user.links.profile)!)
            // TODO: Create SwiftUI modifier to add this support based on debug mode
//                .environment(\.openURL, OpenURLAction { url in
//                    print("Open \(url)")
//                    return .handled
//                })
                .foregroundStyle(.black)
                .padding(4)
                .background(.thinMaterial)
            Text(photo.description ?? "")
                .padding(4)
                .background(.thinMaterial)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .bottomLeading
        )
        .padding()
    }
}

#Preview {
    PhotoView(photo: Photos.loadSampleData().first!)
}

#Preview("Image Error") {
    PhotoView(photo: Photos.loadInvalidImageData().first!)
}
