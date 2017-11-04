//
//  CameraViewController.swift
//  KeepInTouch
//
//  Created by Mitchell Gant on 11/3/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    
    var captureSession = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    var cameraPosition: AVCaptureDevice.Position!
    var getFrame = false
    var context = CIContext()
    var requests = [VNRequest]()
    var toEmail = ""
    
    @IBOutlet weak var outputView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //camera setup
        cameraPosition = .back
        prepareCamera()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EmailViewController {
            destination.toEmail = self.toEmail
        } else {
            super.prepare(for: segue, sender: self)
        }
    }
    
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: cameraPosition).devices
        captureDevice = availableDevices.first
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 15)
            captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 15)
            captureDevice.unlockForConfiguration()
            
        } catch {
            print("error with setting up capture device")
            print(error)
        }
        beginSession()
        
    }
    
    
    
    func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error)
        }
        
        let preview = AVCaptureVideoPreviewLayer(session: captureSession)
        preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer = preview
        outputView.layer.addSublayer(previewLayer)
        previewLayer.frame = outputView.bounds
        print(outputView.frame)
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String) :NSNumber(value:kCVPixelFormatType_32BGRA)]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        
        let picQueue = DispatchQueue(label: "com.mitchellgant.AniGif")
        dataOutput.setSampleBufferDelegate(self, queue: picQueue)
        
        
        
        
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if getFrame {
            getFrame = false
            if let image = self.captureFrame(buffer: sampleBuffer) {
                processImage(image, completion: {
                    //nothing for right now
                })
            }
            
        }
        
    }
    
    
    
    
    func processImage (_ image: UIImage, completion: () -> Void) {
        print("processing image" )
        let data = UIImagePNGRepresentation(image)
        let microsoftURL = URL(string: "https://eastus.api.cognitive.microsoft.com/vision/v1.0/ocr?en&subscription-key=9caa6e915a534b339cc74be5e076aaaf")
        var request = URLRequest(url: microsoftURL!)
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = data!
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print("fetching data")
            guard error == nil else {
                print("something messed up")
                print(error?.localizedDescription)
                return
            }
            
            var returnedData = [String]()
        
            if let jsonData = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) {
                if let responseData = jsonData as? [String: Any] {
                    let readableData = responseData["regions"] as! [[String: Any]]
                    for dataChunk in readableData {
                        if let lineSet = dataChunk["lines"] as? [[String: Any]] {
                            for line in lineSet {
                                var lineString = ""
                                if let wordSet = line["words"] as? [[String: String]] {
                                    for word in wordSet {
                                        lineString += " "
                                       lineString += word["text"]!
                                    }
                                }
                               returnedData.append(lineString)
                             }
                        }
                    }
                } else {
                    print("cannot cast readableData")
                }
                print(returnedData)
                print("--------------")
                print(self.getEmail(lineData: returnedData))
                
                if let email = self.getEmail(lineData: returnedData) {
                    self.toEmail = email
                    let alert = UIAlertController(title: "Next Steps", message: "Select an option below.", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: "Cancel", style: .default)
                    let justSave = UIAlertAction(title: "Just Save Business Card", style: .default, handler: { (action) in
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        self.dismiss(animated: true, completion: {
                            let alert2 = UIAlertController(title: "Image saved to camera roll.", message: nil, preferredStyle: .alert)
                            alert2.addAction(UIAlertAction(title: "OK", style: .default))
                            self.present(alert2, animated: true, completion: nil)
                        })
                        
                    })
                    
                    let saveContinue = UIAlertAction(title: "Save and Continue to Email", style: .default, handler: { (action) in
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        self.performSegue(withIdentifier: "toEmailVC", sender: self)
                    })
                    
                    alert.addAction(cancel)
                    alert.addAction(justSave)
                    alert.addAction(saveContinue)
                    
                    
                    self.present(alert, animated: true, completion: nil)
                } else {
                    //we didnt find an email
                }
                
            }
            
        }
        task.resume()
        
        
        
    }
    
    func captureFrame(buffer: CMSampleBuffer) -> UIImage? {
        if let pixBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvImageBuffer: pixBuffer)
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixBuffer), height: CVPixelBufferGetHeight(pixBuffer))
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
        
    }
    
    
    
    
    @IBAction func takePictureBtnPressed(_ sender: Any) {
        
        getFrame = true
        
    }
    
    func getEmail(lineData: [String]) -> String? {
        var emailLine = ""
        for line in lineData {
            if line.contains("@") {
                emailLine = line
                break
            }
        }
    
        var words = emailLine.split(separator: " ")
        var email: String?  = nil
        for word in words {
            if word.contains("@") {
                email = String(word)
                break
            }
        }
        return email
    
    }
    



}
