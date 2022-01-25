//
//  ImageScan.swift
//  ImageScan
//
//  Created by Mohamed Attar on 28/08/2021.
//


import UIKit
import Vision
import MLKit
import MLImage

class ImageScan {
    
    
    init(image: UIImage? = nil) {
        self.image = image
    }
    
    private var image: UIImage?
    
    
    func vision(completion: @escaping (String) -> () ) {
        // Get the CGImage on which to perform requests.
        guard let cgImage = image?.cgImage else { return }

        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest { request, error in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }.joined(separator: " ")
            completion(recognizedStrings)
        }

        do {
            request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
    }
    
    func googleMLKit(completion: @escaping (String) -> () ) {
        let textRecognizer = TextRecognizer.textRecognizer()
        let visionImage = VisionImage(image: image!)
        visionImage.orientation = image!.imageOrientation
        
        textRecognizer.process(visionImage) { result, error in
          guard error == nil, let result = result else {
            return
          }
            completion(result.text)
        }
    }
    
}
