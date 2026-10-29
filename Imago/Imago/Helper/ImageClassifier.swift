//
//  ImageClassifier.swift
//  Imago
//
//  Created by Christopher Combes on 10/26/26.
//

@preconcurrency import Vision
import CoreML
import UIKit

// TODO: Make testable for "error"
func classifyImage(cgImage: CGImage, completion: @escaping (String?) -> Void) async {
    do {
        let config = MLModelConfiguration()
        let mlModel = try VNCoreMLModel(for: MobileNetV2(configuration: config).model)

        let request = VNCoreMLRequest(model: mlModel) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                return
            }
            
            let maxTwoResults = topResult.identifier.split(separator: ",").prefix(2)
            let maxTwoResultsString = maxTwoResults.joined(separator: ",")
            let confidenceString = String(format: "%.0f", topResult.confidence * 100)
            completion(maxTwoResultsString + " (\(confidenceString)%)")

            print("Prediction: \(topResult.identifier) with confidence: \(topResult.confidence)")
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion("Failed: \(error)")
            }
        }
    } catch {
        completion("Failed: \(error)")
    }
}
