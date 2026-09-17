//
//  ImageFetcher.swift
//  Imago
//
//  Created by Christopher Combes on 9/4/26.
//

import Combine
import UIKit

// TODO: Adding to git as part of iteration but will remove in next commit.
class ImageFetcher: ObservableObject {
    @Published var image: UIImage?
    let url = ""
    let loadSampleImage = false
    
    init(url: String = "", loadSampleImage: Bool = false) {
        if loadSampleImage {
        }
    }
    
    private func fetchImage(url: String) async throws -> UIImage {
        guard let imageURL = URL(string: url)
        else {
            throw URLError(.badURL)
        }
        let request = URLRequest(url: imageURL)
        let (data, _) = try await URLSession.shared.data(for: request, delegate: nil)
        guard let image = UIImage(data: data)
        else {
            throw URLError(.badServerResponse)
        }

        return image
    }
}

//func loadImage(index: Int) async -> UIImage {
//    let imageURL = URL(string: "https://picsum.photos/200/300")!
//    let request = URLRequest(url: imageURL)
//    let (data, _) = try! await URLSession.shared.data(for: request, delegate: nil)
//    print("Finished loading image \(index)")
//    return UIImage(data: data)!
//}
