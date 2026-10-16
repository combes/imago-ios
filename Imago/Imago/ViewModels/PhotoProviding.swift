//
//  PhotoProviding.swift
//  Imago
//
//  Created by Christopher Combes on 10/16/26.
//

import Foundation

protocol PhotoProviding {
    var isLoading: Bool { get }
    var photos: [Photo] { get }
    var error: Error? { get }

    func fetchPhotos(searchText: String)
}
