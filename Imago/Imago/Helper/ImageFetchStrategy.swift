//
//  ImageFetchStrategy.swift
//  Imago
//
//  Created by Christopher Combes on 10/28/26.
//

import SwiftUI

enum ImageFetchStrategy {
    case cache(url: URL)
    case download(url: URL, isSampleData: Bool)
    case render(image: Image?)
    
    func fetch() async -> CGImage? {
        var cgImage: CGImage?
        switch self {
        case .cache(let url):
            if #available(iOS 27, *) {
                cgImage = await fetchCachedImage(url: url)
            }
        case .download(let url, let isSampleData):
            cgImage = await downloadImage(url: url, isSampleData: isSampleData)
        case .render(let image):
            cgImage = await fetchRenderedImage(image: image)
        }
        return cgImage
    }
    
    // OPTION #1: Render the `Image` from the `AsyncImage` call,
    // instead of re-downloading it (in order to access the image data itself).
    func fetchRenderedImage(image: Image?) async -> CGImage? {
        guard let image else { return nil }
        let renderer = ImageRenderer(content: image)
        return renderer.cgImage
    }
    
    // OPTION #2: Download the image again so we can access the underlying
    // image data (`AsyncImage` does not provide for this).
    func downloadImage(url: URL, isSampleData: Bool) async -> CGImage? {
        var cgImage: CGImage?
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if !isSampleData {
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200
                else
                {
                    throw URLError(.badServerResponse)
                }
            }
            
            if let image = UIImage(data: data) {
                cgImage = image.cgImage
            }
        } catch {
            print(error.localizedDescription)
        }
        return cgImage
    }

    // OPTION #3: Fetch the image cached from call to `AsyncImage`.
    @available(iOS 27, *)
    func fetchCachedImage(url: URL) async -> CGImage? {
        var cgImage: CGImage?
        let request = URLRequest(url: url)
        
        // Access cached response for this URL if available
        if  let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            let rawData = cachedResponse.data
            if let image = UIImage(data: rawData) {
                cgImage = image.cgImage
            }
        } else {
            print("Could not find data in cache for URL \(url.absoluteString).")
        }
        return cgImage
    }
}
