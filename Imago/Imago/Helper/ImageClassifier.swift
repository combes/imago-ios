//
//  ImageClassifier.swift
//  Imago
//
//  Created by Christopher Combes on 10/26/26.
//

@preconcurrency import Vision
import CoreML
import UIKit

// MARK: Code abstractions for testing a "failed" case of image classification for UI error case

enum ClassificationError: Error {
    case failed
}
extension ClassificationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .failed:
            return NSLocalizedString("Failed to classify.", comment: "Failed to classify an image")
        }
    }
}

protocol ClassifyingHandler: Sendable {
    init(cgImage image: CGImage, options: [VNImageOption : Any])
    func perform(_ requests: [VNRequest]) throws
}

class FailingClassifier: NSObject, ClassifyingHandler {
    required public init(cgImage image: CGImage, options: [VNImageOption : Any] = [:]) {}
    func perform(_ requests: [VNRequest]) throws {
        throw ClassificationError.failed
    }
}

enum Classifier {
    case `default`
    case failing
}

struct VNImageRequestHandlerType: ClassifyingHandler {
    var handler: VNImageRequestHandler
    init(cgImage: CGImage, options: [VNImageOption : Any] = [:]) {
        self.handler = VNImageRequestHandler(cgImage: cgImage, options: options)
    }
    func perform(_ requests: [VNRequest]) throws {
        try handler.perform(requests)
    }
}
struct ClassifierFactory {
    static func make(type: Classifier, cgImage: CGImage) -> ClassifyingHandler {
        switch type {
        case .default:
            return VNImageRequestHandlerType(cgImage: cgImage, options: [:])
        case .failing:
            return FailingClassifier(cgImage: cgImage)
        }
    }
}

// MARK: Image classification using ML model MobileNetV2

struct ClassificationResult: Equatable {
    let classifications: [String]
    let percent: Float
    func confidenceString() -> String {
        String(format: "%.0f%%", percent)
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        if lhs.classifications.sorted() != rhs.classifications.sorted() {
            return false
        }
        return lhs.percent.isEqual(to: rhs.percent)
    }
}

class ImageClassifier {
    private let classifier: Classifier
    init(classifier: Classifier = .default) {
        self.classifier = classifier
    }

    func classifyImage(cgImage: CGImage,
                       completion: @escaping (Result<ClassificationResult, ClassificationError>) -> Void) {
        do {
            let config = MLModelConfiguration()
            let mlModel = try VNCoreMLModel(for: MobileNetV2(configuration: config).model)
            
            let request = VNCoreMLRequest(model: mlModel) { request, error in
                guard let results = request.results as? [VNClassificationObservation],
                      let topResult = results.first else {
                    return
                }
                
                let maxTwoResults = topResult.identifier.split(separator: ",").prefix(2)
                let items = maxTwoResults.map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                let result = ClassificationResult(classifications: items,
                                                  percent: topResult.confidence * 100)
                completion(.success(result))
            }
            
            let handler = ClassifierFactory.make(type: classifier, cgImage: cgImage)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    completion(.failure(.failed))
                }
            }
        } catch {
            completion(.failure(.failed))
        }
    }
}
