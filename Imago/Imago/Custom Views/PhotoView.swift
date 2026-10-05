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
    
    @Environment(\.sampleData) var sampleData
    
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    private var isUnsplashLabelHidden: Bool {
        if sampleData {
            // Always hide since sample images are not from Unsplash
            return true
        }
        if totalZoom == 1 {
            return false
        }
        return true
    }
    
    var body: some View {
        // TODO: Resolve code duplication with code in ContentView
        VStack(alignment: .center) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .background(.gray.opacity(0.1))
                    
                case .success(let image):
                    VStack(alignment: .leading) {
                        image
                            .resizable()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(currentZoom + totalZoom)
                            .gesture(
                                MagnifyGesture()
                                    .onChanged { value in
                                        currentZoom = value.magnification - 1
                                    }
                                    .onEnded { value in
                                        totalZoom += currentZoom
                                        currentZoom = 0
                                        if totalZoom < 1 {
                                            // Reset zoom if image is smaller than original size
                                            totalZoom = 1
                                        }
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
                            .overlay(alignment: .bottom) {
                                HStack {
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text("Source: Unsplash")
                                            .font(.footnote)
                                            .foregroundStyle(.white)
                                            .padding([.leading, .trailing], 8)
                                            .background(.black)
                                            .opacity(0.6)
                                    }
                                }
                                .opacity(isUnsplashLabelHidden ? 0 : 1)
                            }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Link(photo.user.name, destination: URL(string: photo.user.links.profile)!)
                            // TODO: Create SwiftUI modifier to add this support based on debug mode
                            //                .environment(\.openURL, OpenURLAction { url in
                            //                    print("Open \(url)")
                            //                    return .handled
                            //                })
                                .foregroundStyle(.foreground)
                                .font(.subheadline)
                                .background(.thinMaterial)
                            Text(photo.description ?? "")
                                .font(.footnote)
                                .background(.thinMaterial)
                                .opacity(photo.description.isNilOrEmpty ? 0 : 1)
                        }
                        .padding(.leading, 4)
                    }
                    Spacer()
                    
                case .failure:
                    StatusView(image: "photo.badge.exclamationmark",
                               color: .gray.opacity(0.5),
                               title: "Empty")
                    
                @unknown default:
                    EmptyView()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .ignoresSafeArea(edges: .top)
    }
}

#Preview("Sample Photo") {
    PhotoView(photo: Photos.loadSampleData().first!)
        .environment(\.sampleData, true)
}

#Preview("Image Error") {
    PhotoView(photo: Photos.loadInvalidImageData().first!)
        .environment(\.sampleData, true)
}
