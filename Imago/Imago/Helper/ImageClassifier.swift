//
//  ImageClassifier.swift
//  Imago
//
//  Created by Christopher Combes on 10/26/26.
//

@preconcurrency import Vision
import CoreML
import UIKit

// TODO: Encapsulate and cleanup
func classifyImage(ciImage: CIImage) async {
    do {
        let config = MLModelConfiguration()
        let mlModel = try VNCoreMLModel(for: MobileNetV2(configuration: config).model)

        let request = VNCoreMLRequest(model: mlModel) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                return
            }
            
            print("Prediction: \(topResult.identifier) with confidence: \(topResult.confidence)")
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform Vision request: \(error)")
            }
        }
    } catch {
        print("Image recognition failed: \(error.localizedDescription)")
    }
}
