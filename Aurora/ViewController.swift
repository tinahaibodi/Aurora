//
//  ViewController.swift
//  Aurora
//
//  Created by Amirmehdi Sharifzad on 2018-02-24.
//  Copyright © 2018 Hack The Valley II. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    
    // 2) access the AVSpeechSynthesizer Class
    let speakTalk = AVSpeechSynthesizer()
    
    // 3) create AVSpeechutterance instance using string
    let Aurora = AVSpeechUtterance(string: "No, my name is Aurora" )
    
    @IBOutlet weak var theWordsInTheTextField: UITextField!
    
    @IBAction func speakText(sender: AnyObject) {
        
        // *create AVSpeechUtterance instance using text in the field
        let speakText = AVSpeechUtterance(string: theWordsInTheTextField.text!)
        
        // *adjust the rate and pitch of each Utterance instance in the function
        // -rate: float (min, max) = (0.0 to 1.0)
        // -pitchMultiplier:float  (min,max) = (0.5 to 2.0)
        Aurora.rate = 0.6
        Aurora.pitchMultiplier = 2
        speakText.rate = 0.2
        speakText.pitchMultiplier = 0.1
        
        // 4) pass the utterance instance(s) to the speakUtterance methods queue
        speakTalk.speak(speakText)
        speakTalk.speak(Aurora)
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupCaptureSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func setupCaptureSession() {
        // creates a new capture session
        let captureSession = AVCaptureSession()
        
        // search for available capture devices
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        
        // get capture device, add device input to capture session
        do {
            if let captureDevice = availableDevices.first {
                captureSession.addInput(try AVCaptureDeviceInput(device: captureDevice))
            }
        } catch {
            print(error.localizedDescription)
        }
    
        // setup output, add output to our capture session
        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(captureOutput)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
        
        
        captureSession.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        let request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            guard let results = finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let Observation = results.first else { return }
            
            DispatchQueue.main.async(execute: {
                self.label.text = "\(Observation.identifier)"
            })
        }
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        // executes request
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
}

