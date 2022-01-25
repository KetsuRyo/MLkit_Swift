//
//  ViewController.swift
//  ScanAway
//
//  Created by Mohamed Attar on 28/08/2021.
//

import UIKit
import Vision
import MLKitEntityExtraction


class HomeViewController: UIViewController {
    
    var addImage = UIButton()
    let scanButton = UIButton()
    
    let vc = UIImagePickerController()
    let segmentControl = UISegmentedControl (items: ["Apple's Vision", "Google's MLKit"])
    
    var imageToS: UIImage?
    
    var isImageSelected = false
    
    let waitingAlert = UIAlertController(title: "Scanning...", message: nil, preferredStyle: .alert)
    
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
                DispatchQueue.global().async {
                    imageToScan.vision { text in
                        DispatchQueue.main.async {
                            self.waitingAlert.dismiss(animated: true) {
                                print(text)
                                scannedVC.text = text
                                self.navigationController?.pushViewController(scannedVC, animated: true)
                            }
                        }
                    }
                }
            default:
                imageToScan.googleMLKit { text in
                    self.waitingAlert.dismiss(animated: true) {
                        print(text)
                        self.inspectText(viewController: scannedVC,result2: text)
                        //   scannedVC.text = text
                        self.navigationController?.pushViewController(scannedVC, animated: true)
                    }
                   
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
    open func inspectText(viewController: UIViewController, result2: String) {
        let options = EntityExtractorOptions(modelIdentifier: EntityExtractionModelIdentifier.english)
        let entityExtractor = EntityExtractor.entityExtractor(options: options)
        entityExtractor.downloadModelIfNeeded(completion: {_ in
                  // If the error is nil, the download completed successfully.
                })
        entityExtractor.annotateText(
            result2,
            completion: {
                res, error in
                if (res != nil){
                    for annotation in res! {
                        let entities = annotation.entities
                        for entity in entities {
                            switch entity.entityType {
                                case EntityType.phone:
                                ScannedViewController().text.append(entity.description)
                                case EntityType.address:
                                ScannedViewController().text.append(entity.description)
                                              // Add additional cases as needed.
                                default:
                                print("Entity: %@", entity);
                                }
                        }
                }
            }
            }
        )
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
            //            self.navigationController?.pushViewController(scannedVC, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}
