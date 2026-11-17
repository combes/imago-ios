//
//  PhotoView.swift
//  Imago
//
//  Created by Christopher Combes on 9/22/26.
//

import SwiftUI

struct PhotoView: View {
    let photo: Photo
    var classifier: Classifier = .default
    
    private var imageURL: URL  {
        photo.url(forType: .regular)
    }
    
    @Environment(\.sampleData) var isSampleData
    
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    @State private var isDragging = false
    @State private var offset = CGSize.zero
    @State private var totalOffset = CGSize.zero
    @State private var isDragActive: Bool = false
    @State private var renderedImage: Image?
    @State private var imageClassificationOne: String?
    @State private var imageClassificationTwo: String?
    @State private var percentClassification: String?
    @State private var error: Error?
    private var isZoomed: Bool {
        totalZoom > 1
    }
    
    private var shouldHideLabels: Bool {
        isDragging || isZoomed
    }
    
    private var isUnsplashLabelHidden: Bool {
        if isSampleData || shouldHideLabels {
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
                } else {
                    isDragActive = true
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
        isDragActive = false
        offset = .zero
        totalOffset = .zero
        totalZoom = 1
    }
    
    var body: some View {
        ZStack {
            // TODO: Resolve code duplication with code in ContentView
            VStack(alignment: .center) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .scaleEffect(2)
                            .frame(maxWidth: .infinity)
                            .aspectRatio(1, contentMode: .fill)
                        
                    case .success(let image):
                        VStack(alignment: .leading) {
                            image
                                .resizable()
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .offset(offset)
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(currentZoom + totalZoom)
                            // Disovered drag gesture must be added before magnify gesture
                                .gesture(dragGesture, isEnabled: isDragActive)
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
                                .onAppear() {
                                    // Save reference to generated `Image` so we can use it with the image classifier
                                    renderedImage = image
                                }
                                .overlay(alignment: .bottom) {
                                    if !isUnsplashLabelHidden {
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
                                    }
                                }
                            
                            if !shouldHideLabels {
                                VStack(alignment: .leading, spacing: 4) {
                                    Link(photo.user.name, destination: URL(string: photo.user.links.profile)!)
                                        .foregroundStyle(.foreground)
                                        .font(.subheadline)
                                        .background(.thinMaterial)
                                    if !photo.description.isNilOrEmpty {
                                        Text(photo.description ?? "")
                                            .font(.footnote)
                                            .background(.thinMaterial)
                                    }
                                }
                                .padding(.leading, 4)
                            }
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
            
            if !shouldHideLabels {
                VStack(alignment: .center) {
                    Spacer()
                    HStack {
                        if let error {
                            Text(error.localizedDescription)
                                .fontWeight(.bold)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(.red)
                        }
                        if let imageClassificationOne {
                            Text(imageClassificationOne)
                                .fontWeight(.bold)
                                .padding(8)
                                .background(.green)
                                .cornerRadius(8)
                            if let imageClassificationTwo {
                                Text(imageClassificationTwo)
                                    .fontWeight(.bold)
                                    .padding(8)
                                    .background(.green)
                                    .cornerRadius(8)
                            }
                            if let percentClassification {
                                Text(percentClassification)
                                    .fontWeight(.bold)
                                    .padding(8)
                                    .background(.black)
                                    .foregroundStyle(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    // TODO: Add image animation
                    Button("Identify", systemImage: "wand.and.sparkles") {
                        // Three strategies to obtaining a "rendered" image for classification:
                        // 1. Grab a rendering in the `onAppear` event (see above).
                        let imageFetcher: ImageFetchStrategy = .render(image: renderedImage)
                        // 2. Find a cached version of the image after loading from network (iOS 27).
                        //.cache(url: imageURL)
                        // 3. Download the image directly (not efficient).
                        //.download(url: imageURL, isSampleData: isSampleData)
                        Task {
                            if let cgImage = await imageFetcher.fetch() {
                                let classifier = ImageClassifier(classifier: classifier)
                                classifier.classifyImage(cgImage: cgImage, completion: { result in
                                    switch result {
                                    case .failure(let error):
                                        self.error = error
                                        break
                                    case .success(let classification):
                                        imageClassificationOne = classification.classifications.first
                                        if classification.classifications.count > 1 {
                                            imageClassificationTwo = classification.classifications[1]
                                        }
                                        percentClassification = classification.confidenceString()
                                    }
                                })
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.blue)
                }
            }
        }
    }
}

#Preview("Sample Photo") {
    PhotoView(photo: Photos.loadSampleData().first!)
        .environment(\.sampleData, true)
}

#Preview("Classification Error") {
    PhotoView(photo: Photos.loadSampleData().first!, classifier: .failing)
        .environment(\.sampleData, true)
}

#Preview("Image Error") {
    PhotoView(photo: Photos.loadInvalidImageData().first!)
        .environment(\.sampleData, true)
}
