//
//  QRViewController.swift
//  CoreML in ARKit
//
//  Created by YouYue on 10/3/18.
//  Copyright © 2018 CompanyName. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import PopupDialog
import SVProgressHUD

class QRViewController: UIViewController {
    @IBOutlet weak var nextStepBtn: UIButton!
    @IBOutlet weak var banner: UITextView!
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var haveTriedURL = false
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5,
                                      AVMetadataObject.ObjectType.qr]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            print("Set capture metadata")
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: nextStepBtn)
        view.bringSubview(toFront: banner)
        
        nextStepBtn.addTarget(self, action: #selector(nextStepAction), for: .touchUpInside)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }
        // Do any additional setup after loading the view.
    }
    @objc
    func nextStepAction(sender: UIButton!) {
         performSegue(withIdentifier: "toSC", sender: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
           if metadataObj.stringValue != nil{
                if self.haveTriedURL == false {
                    self.haveTriedURL = true
                    let parameters: Parameters = [
                        "foo": [1,2,3],
                        "bar": [
                            "baz": "qux"
                        ]
                    ]
                    SVProgressHUD.show()
                    print(metadataObj.stringValue!)
                    Alamofire.request(metadataObj.stringValue!, method: .get)
                        .responseJSON { response in
                            debugPrint(response)
                            SVProgressHUD.dismiss()
                            // Prepare the popup assets
                            let title = "The status is sent"
                            let message = "This is the message section of the popup dialog default view"
                            let image = UIImage(named: "pexels-photo-103290")
                            
                            // Create the dialog
                            let popup = PopupDialog(title: title, message: message, image: image)
                            
                            
                            let button = DefaultButton(title: "OK", height: 60) {
                                print("Ah, maybe next time :)")
                            }
                            
                            // Add buttons to dialog
                            // Alternatively, you can use popup.addButton(buttonOne)
                            // to add a single button
                            popup.addButtons([button])
                            
                            // Present dialog
                            self.present(popup, animated: true, completion: nil)
                            
                        }
                    
                }
            }
        }
    }
}
