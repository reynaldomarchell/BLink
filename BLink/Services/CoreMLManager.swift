//
//  CoreMLManager.swift
//  BLink
//
//  Created by reynaldo on 25/03/25.
//

import Foundation
import Vision
import CoreML
import UIKit

class CoreMLManager {
    static let shared = CoreMLManager()
    
    // This would be your trained model for bus plate recognition
    // private var plateRecognitionModel: VNCoreMLModel?
    
    private init() {
        // In a real app, you would load your CoreML model here
        // setupModel()
    }
    
    /*
    private func setupModel() {
        do {
            // Load the Core ML model
            if let modelURL = Bundle.main.url(forResource: "BusPlateRecognition", withExtension: "mlmodelc") {
                let model = try MLModel(contentsOf: modelURL)
                plateRecognitionModel = try VNCoreMLModel(for: model)
            }
        } catch {
            print("Failed to load Core ML model: \(error)")
        }
    }
    */
    
    func recognizePlateNumber(in image: UIImage, completion: @escaping (String?) -> Void) {
        // In a real app, this would use Vision framework to detect and recognize text
        // For now, we'll simulate the process
        
        // Convert UIImage to CIImage
        guard let ciImage = CIImage(image: image) else {
            completion(nil)
            return
        }
        
        // Create a request handler
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        // Create a text recognition request
        let textRequest = VNRecognizeTextRequest { request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(nil)
                return
            }
            
            // Process the recognized text
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            // Look for text that matches a license plate format (e.g., "B 1234 ABC")
            let platePattern = #"[A-Z]\s\d{4}\s[A-Z]{3}"#
            let plateNumbers = recognizedStrings.filter { string in
                string.range(of: platePattern, options: .regularExpression) != nil
            }
            
            if let plateNumber = plateNumbers.first {
                completion(plateNumber)
            } else {
                // If no plate is found, generate a random one for demo purposes
                completion(BusDataManager.shared.generateRandomPlateNumber())
            }
        }
        
        // Set recognition level
        textRequest.recognitionLevel = .accurate
        
        // Perform the request
        do {
            try handler.perform([textRequest])
        } catch {
            print("Failed to perform text recognition: \(error)")
            completion(nil)
        }
    }
    
    func checkIfBusMatchesRoute(plateNumber: String, startPoint: String, destination: String, completion: @escaping (Bool) -> Void) {
        // In a real app, this would query your local database to check if the bus with this plate
        // serves the route between startPoint and destination
        
        // For demo purposes, we'll simulate a random match
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let isMatch = Bool.random()
            completion(isMatch)
        }
    }
}
