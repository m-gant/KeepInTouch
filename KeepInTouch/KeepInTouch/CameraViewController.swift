//
//  CameraViewController.swift
//  KeepInTouch
//
//  Created by Mitchell Gant on 11/3/17.
//  Copyright © 2017 Mitchell Gant. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    
    var captureSession = AVCaptureSession()
    var previewLayer: CALayer!
    var captureDevice: AVCaptureDevice!
    var cameraPosition: AVCaptureDevice.Position!
    var getFrame = false
    var context = CIContext()
    
    
    @IBOutlet weak var outputView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //camera setup
        cameraPosition = .back
        prepareCamera()
        
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
    
    
    



}
