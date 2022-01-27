import UIKit
import Vision
import MLKitEntityExtraction
import CoreLocation
import MapKit


class HomeViewController: UIViewController {
    
    var addImage = UIButton()
    let scanButton = UIButton()
    
    let vc = UIImagePickerController()
    let segmentControl = UISegmentedControl (items: ["Chinese", "English"])
    
    var imageToS: UIImage?
    
    var isImageSelected = false
    
    let waitingAlert = UIAlertController(title: "Scanning...", message: nil, preferredStyle: .alert)
    
    
    // Jason
    var entityExtractor = EntityExtractor.entityExtractor(
      options: EntityExtractorOptions(modelIdentifier: EntityExtractionModelIdentifier.english))
    var entityChineseExtractor = EntityExtractor.entityExtractor(
      options: EntityExtractorOptions(modelIdentifier: EntityExtractionModelIdentifier.chinese))
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        title = "Scan Away!"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(reset))
        
        
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        waitingAlert.view.addSubview(loadingIndicator)
        
        view.addSubview(segmentControl)
        segmentControl.selectedSegmentIndex = 0

        vc.delegate = self
        vc.allowsEditing = true
        
        createButton()
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            
            addImage.leadingAnchor.constraint(equalTo: view.leadingAnchor,  constant: 15),
            addImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            addImage.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 15),
            addImage.heightAnchor.constraint(equalTo: addImage.widthAnchor),
            
            scanButton.heightAnchor.constraint(equalToConstant: 60),
            scanButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            scanButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            scanButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func reset()
    {
        isImageSelected = false
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 140, weight: .bold, scale: .large)
        let icon = UIImage(systemName: "plus.square.fill", withConfiguration: largeConfig)?.withTintColor(.label, renderingMode: .alwaysOriginal)
        
        addImage.setImage(icon, for: .normal)
        
        segmentControl.selectedSegmentIndex = 0

    }
    
    func createButton() {
        view.addSubview(addImage)
        view.addSubview(scanButton)
        
        scanButton.setImage(UIImage(systemName: "doc.text.fill.viewfinder")?.withTintColor(.label, renderingMode: .alwaysOriginal), for: .normal)
        scanButton.setTitle("  Scan", for: .normal)
        scanButton.layer.cornerRadius = 15
        scanButton.backgroundColor = .systemGray2
        scanButton.setTitleColor(.label, for: .normal)
        
        scanButton.addAction(UIAction(handler: { _ in
            if !self.isImageSelected {
                let alert = UIAlertController(title: "Please choose an image before proceeding.", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.present(self.waitingAlert, animated: true, completion: nil)


            let imageToScan = ImageScan(image: self.imageToS)
            let scannedVC = ScannedViewController()

            scannedVC.img = self.imageToS!
            
            

            switch self.segmentControl.selectedSegmentIndex {

                
                
            case 0:
                
                    imageToScan.googleChineseMLKit { text in
                        self.downloadModelAndChineseAnnotate(text: text)                    }
                
                
            default:
                imageToScan.googleMLKit { text in
               
                    self.downloadModelAndAnnotate(text: text)
                    
                }
            }
            
        }), for: .touchUpInside)
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 140, weight: .bold, scale: .large)
        let icon = UIImage(systemName: "plus.square.fill", withConfiguration: largeConfig)?.withTintColor(.label, renderingMode: .alwaysOriginal)
        
        addImage.setImage(icon, for: .normal)
        
        addImage.addAction(UIAction(handler: { _ in
            self.feedback()
        }), for: .touchDown)
        
        addImage.layer.cornerRadius = 15
        addImage.clipsToBounds = true
        addImage.showsMenuAsPrimaryAction = true
        addImage.menu = createMenu()
        
        addImage.translatesAutoresizingMaskIntoConstraints = false
        scanButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func createMenu() -> UIMenu {
        let cameraAction = UIAction(title: "Camera", image: UIImage(systemName: "camera.fill")) { _ in
            self.vc.sourceType = .camera
            self.present(self.vc, animated: true, completion: nil)
        }
        let photoLibraryAction = UIAction(title: "Photo Library", image: UIImage(systemName: "photo.on.rectangle.angled")) { _ in
            self.vc.sourceType = .photoLibrary
            self.present(self.vc, animated: true, completion: nil)
        }
        
        let menuActions = [cameraAction, photoLibraryAction]
        let menu = UIMenu(options: .displayInline, children: menuActions)
        
        return menu
    }
    
    func feedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        print("button tapped")
    }

    
    // ---------------------------------------
    func downloadModelAndChineseAnnotate(text: String) {

        let extractor = entityChineseExtractor
        extractor.downloadModelIfNeeded(completion: {
          [weak self]
          error in
          guard let self = self else { return }
          guard error == nil else {
            print("Failed to download model with error \(error!)")
            return
          }
          self.annotateText(text: text, extractor: extractor)
        })
    }
    
    
    
    
    func downloadModelAndAnnotate(text: String) {

        let extractor = entityExtractor
        extractor.downloadModelIfNeeded(completion: {
          [weak self]
          error in
          guard let self = self else { return }
          guard error == nil else {
            print("Failed to download model with error \(error!)")
            return
          }
          self.annotateText(text: text, extractor: extractor)
        })
    }
    func coordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) {
            (placemarks, error) in
            guard error == nil else {
                print("Geocoding error: \(error!)")
                completion(nil)
                return
            }
            completion(placemarks?.first?.location?.coordinate)
        }
    }
    
    func annotateText(text: String,  extractor: EntityExtractor!) {

        extractor.annotateText(text, completion: {
            
            [weak self]
            result, error in
            
            guard let result = result else {
              print("Result is nil.")
              return
            }
            if result.count == 0 {
                print("Result is empty.")
            } else {
                
              for annotation in result {

                  let annotationString = AnnotationUtil().stringFromAnnotation(annotation: annotation)
                  if (annotationString == "phone") {
                      let textLocation = annotation.range.location
                      let textLength = annotation.range.length
                      let start = text.index(text.startIndex, offsetBy: textLocation)
                      let endNumber = text.count - textLocation - textLength
                      let endLocation = 0 - endNumber
                      let end = text.index(text.endIndex, offsetBy: endLocation)
                      let range = start..<end

                      let phoneNumber = text[range]
                      self!.waitingAlert.dismiss(animated: true) {
                          if let url = URL(string: "tel://\(phoneNumber)") {
                              UIApplication.shared.openURL(url)
                          };
                     //     self?.navigationController?.pushViewController(ScannedViewController(), animated: true)
                      }
                  }else if (annotationString == "address") {
                      
                      let textLocation = annotation.range.location
                      let textLength = annotation.range.length
                      let start = text.index(text.startIndex, offsetBy: textLocation)
                      let endNumber = text.count - textLocation - textLength
                      let endLocation = 0 - endNumber
                      let end = text.index(text.endIndex, offsetBy: endLocation)
                      let range = start..<end

                      let address = text[range]
                      
                     self!.waitingAlert.dismiss(animated: true) { [self] in
                          
                      
                              
                             let refreshAlert = UIAlertController(title: "Search?", message: String(address), preferredStyle: UIAlertController.Style.alert)

                              refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction) in
                                  let url = "http://maps.google.co.in/maps?q=\(String(address))"
                                  let objectUrl = URL(string:url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                                  UIApplication.shared.openURL(objectUrl!)
                              }))

                              refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                                  print("Handle Cancel Logic here")
                              }))

                              self!.present(refreshAlert, animated: true, completion: nil)
                              
                            
                          
                 
                      }
                      
                  }
                  
              }
            }
        })
    }
    
    
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageToS = image
            isImageSelected = true
            addImage.setImage(image, for: .normal)
            addImage.imageView?.contentMode = .scaleAspectFit
        }
        
        picker.dismiss(animated: true) {
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
