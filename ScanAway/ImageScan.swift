//
//  ImageScan.swift
//  ImageScan
//
//  Created by Mohamed Attar on 28/08/2021.
//


import UIKit
import Vision
import MLKit
import MLKitTextRecognitionChinese
import MLImage

class ImageScan {
    
    
    init(image: UIImage? = nil) {
        self.image = image
    }
    
    private var image: UIImage?
    
    

    func googleChineseMLKit(completion: @escaping (String) -> () ) {
        let chineseOptions = ChineseTextRecognizerOptions()
        let chineseTextRecognizer = TextRecognizer.textRecognizer(options:chineseOptions)
        let visionImage = VisionImage(image: image!)
        visionImage.orientation = image!.imageOrientation
        
        chineseTextRecognizer.process(visionImage) { result, error in
          guard error == nil, let result = result else {
            return
          }
            completion(result.text)
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
