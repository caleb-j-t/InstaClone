//
//  CameraViewController.swift
//  InstaClone
//
//  Created by Mike Nancett on 6/21/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit
import AVFoundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var cameraView: UIView!
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var picker = UIImagePickerController()
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var addFilterButton: UIButton!
    var image = UIImage(contentsOfFile: "noimage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        self.addFilterButton.hidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    captureSession = AVCaptureSession()
    captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
    let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    
    var error : NSError?
    var input: AVCaptureDeviceInput!
    do {
    input = try AVCaptureDeviceInput(device: backCamera)
    } catch let error1 as NSError {
    error = error1
    input = nil
    }
    
    if (error == nil && captureSession?.canAddInput(input) != nil){
    
    captureSession?.addInput(input)
    
    stillImageOutput = AVCaptureStillImageOutput()
    stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
    
    if (captureSession?.canAddOutput(stillImageOutput) != nil){
    captureSession?.addOutput(stillImageOutput)
    
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
    previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
    cameraView.layer.addSublayer(previewLayer!)
    captureSession?.startRunning()
    }
    }
}

    func didPressTakePhoto(){
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer, error) in
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    
                    self.image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation .Right)
                    
                    self.tempImageView.image = self.image
                    self.tempImageView.hidden = false
                    self.addFilterButton.hidden = false
                }
            })
        }
    }
    
    var didTakePhoto =  Bool()
    
    func didPressPhoto() {
        if didTakePhoto == true {
            tempImageView.hidden = true
            addFilterButton.hidden = true
            didTakePhoto = false
            print("tap")
            
        }else {
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
        }
    }
    

    @IBAction func photoLibraryButton(sender: UIButton) {
        picker.sourceType = .PhotoLibrary
        picker.allowsEditing = true
        presentViewController(picker, animated: true, completion: nil)
        
//        self.tempImageView.hidden = false
//        self.addFilterButton.hidden = false
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("got Image")
        image = info[UIImagePickerControllerOriginalImage] as? UIImage;
        dismissViewControllerAnimated(true, completion: performSegue)
        
    }
    
    func performSegue(){
          performSegueWithIdentifier("chosenPictureSegue", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "chosenPictureSegue" {
            let vc = segue.destinationViewController as! FilterChoice2ViewController
            vc.image = self.image
        }else{
        let vc = segue.destinationViewController as! FilterChoiceViewController
            vc.image = self.image
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
            didPressPhoto()
    }
}
