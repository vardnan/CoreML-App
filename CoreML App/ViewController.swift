//
//  ViewController.swift
//  SeeFOod
//
//  Created by Vardnan Sivarajah on 31/01/2021.
//  Copyright © 2021 Vardnan. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    var userInput = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
            let alert = UIAlertController(title: "Detect anything 🔎", message: "Write the object you want to detect", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "E.g. \"chair\" or \"table\""
            }

            alert.addAction(UIAlertAction(title: "Submit", style: .default, handler: { [weak alert] (_) in
                if let textField = alert?.textFields?[0], let userText = textField.text {
                    //print("User text: \(userText)")
                    self.userInput = "\(userText)"
                    print(self.userInput)
                }
            }))

            self.present(alert, animated: true, completion: nil)
        }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedimage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedimage
            
            guard let ciimage = CIImage(image: userPickedimage) else {
                fatalError("Could not convert to CIImage")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model failed")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("Model failed to process image")
            }
            
            if let firstResult = results.first {
                if firstResult.identifier.contains("\(self.userInput)") {
                    self.navigationItem.title = "This is a \(self.userInput) ✅"
                } else {
                    self.navigationItem.title = "This is not a \(self.userInput) ❌"
                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
        try! handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func CameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}


