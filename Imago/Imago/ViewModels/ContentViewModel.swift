//
//  ContentViewModel.swift
//  Imago
//
//  Created by Christopher Combes on 9/4/26.
//

import Foundation

/*
 do {
     // 1. Call the method
     let images = try await fetchImages()
     // 2. Fetch images method returns
     
     // 3. Call the resize method
     let resizedImages = try await resizeImages(images)
     // 4. Resize method returns
     
     print("Fetched \(images.count) images.")
 } catch {
     print("Fetching images failed with error \(error)")
 }
 // 5. The calling method exits
 
 final class ContentViewModel: ObservableObject {
     
     @Published var images: [UIImage] = []
     
     func fetchData() {
         Task { @MainActor in
             do {
                 self.images = try await fetchImages()
             } catch {
                 // .. handle error
             }
         }
     }
 }
 
 
 func performPOSTURLRequest() async throws(NetworkingError) {
     do {
         /// Configure the URL for our request.
         let url = URL(string: "https://httpbin.org/post")!
         
         /// Create a URLRequest for the POST request.
         var request = URLRequest(url: url)
         
         /// Configure the HTTP method.
         request.httpMethod = "POST"
         
         /// Configure the proper content-type value to JSON.
         request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         
         /// Define the struct of data and encode it to data.
         let postData = PostData(name: "Antoine van der Lee", age: 33)
         let jsonData = try JSONEncoder().encode(postData)
         
         /// Pass in the data as the HTTP body.
         request.httpBody = jsonData
         
         /// Use URLSession to fetch the data asynchronously.
         let (data, response) = try await URLSession.shared.data(for: request)
         
         guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
             throw NetworkingError.invalidStatusCode(statusCode: -1)
         }
         
         guard (200...299).contains(statusCode) else {
             throw NetworkingError.invalidStatusCode(statusCode: statusCode)
         }
         
         /// Decode the JSON response into the PostResponse struct.
         let decodedResponse = try JSONDecoder().decode(PostResponse.self, from: data)
         
         print("The JSON response contains a name: \(decodedResponse.json.name) and an age: \(decodedResponse.json.age)")
     } catch let error as DecodingError {
         throw .decodingFailed(innerError: error)
     } catch let error as EncodingError {
         throw .encodingFailed(innerError: error)
     } catch let error as URLError {
         throw .requestFailed(innerError: error)
     } catch let error as NetworkingError {
         throw error
     } catch {
         throw .otherError(innerError: error)
     }
 }
 
 enum NetworkingError: Error {
     case encodingFailed(innerError: EncodingError)
     case decodingFailed(innerError: DecodingError)
     case invalidStatusCode(statusCode: Int)
     case requestFailed(innerError: URLError)
     case otherError(innerError: Error)
 }
 */
