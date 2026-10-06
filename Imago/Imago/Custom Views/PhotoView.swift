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
    @State private var isDragging = false
    @State private var offset = CGSize.zero
    @State private var totalOffset = CGSize.zero
    private var isZoomed: Bool {
        totalZoom > 1
    }
    
    private var shouldHideLabels: Bool {
        isDragging || isZoomed
    }
    
    private var isUnsplashLabelHidden: Bool {
        if sampleData || shouldHideLabels {
            // Always hide since sample images are not from Unsplash
            return true
        }
        return false
    }

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                if isZoomed {
                    let x = (gesture.translation.width / totalZoom)
                    let y = (gesture.translation.height / totalZoom)
                    offset.width = totalOffset.width + x
                    offset.height = totalOffset.height + y
                    isDragging = true
                }
            }
            .onEnded { _ in
                totalOffset.width = offset.width
                totalOffset.height = offset.height
                isDragging = false
            }
    }
    
    var magnifyGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                currentZoom = value.magnification - 1
            }
            .onEnded { value in
                totalZoom += currentZoom
                currentZoom = 0
                if totalZoom < 1 {
                    // Reset offset and zoom if image is smaller than original size
                    resetZoom()
                }
            }
    }
    
    var tapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                resetZoom()
            }
    }
    
    func resetZoom() {
        offset = .zero
        totalOffset = .zero
        totalZoom = 1
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
                            .offset(offset)
                            .aspectRatio(contentMode: .fit)
                            .scaleEffect(currentZoom + totalZoom)
                        // Disovered drag gesture must be added before magnify gesture
                            .gesture(dragGesture)
                            .gesture(magnifyGesture)
                            .gesture(tapGesture)
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
                                .foregroundStyle(.foreground)
                                .font(.subheadline)
                                .background(.thinMaterial)
                            Text(photo.description ?? "")
                                .font(.footnote)
                                .background(.thinMaterial)
                                .opacity(photo.description.isNilOrEmpty ? 0 : 1)
                        }
                        .padding(.leading, 4)
                        .opacity(shouldHideLabels ? 0 : 1)
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
