//
//  ViewController.swift
//  QRScan
//
//  Created by McKee on 16/8/11.
//  Copyright © 2016年 MCKEELIN. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    var _camera: AVCaptureDevice?
    var _session = AVCaptureSession()
    var _previewLayer = AVCaptureVideoPreviewLayer()
    var _output = AVCaptureMetadataOutput()
    
    /*
    var _tlMask = UIView(frame: CGRectZero)
    var _trMask = UIView(frame: CGRectZero)
    var _blMask = UIView(frame: CGRectZero)
    var _brMask = UIView(frame: CGRectZero)
    
    var _tlhBar = UIView(frame: CGRectZero)
    var _tlvBar = UIView(frame: CGRectZero)
    var _trhBar = UIView(frame: CGRectZero)
    var _trvBar = UIView(frame: CGRectZero)
    var _blhBar = UIView(frame: CGRectZero)
    var _blvBar = UIView(frame: CGRectZero)
    var _brhBar = UIView(frame: CGRectZero)
    var _brvBar = UIView(frame: CGRectZero)
    */
    
    var _codeMode: Int = 2
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameras = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        for camera in cameras!
        {
            if camera.position == AVCaptureDevicePosition.back
            {
                _camera = camera as? AVCaptureDevice;
                _session.sessionPreset = AVCaptureSessionPresetHigh
                
                var input: AVCaptureDeviceInput
                
                do
                {
                    input = try AVCaptureDeviceInput(device: _camera)
                }
                catch{
                    return
                }
                
                let port  = AVCaptureInputPort()
                
                let queue = DispatchQueue(label:"ScanQueue") //DispatchQueue("ScanQueue", nil, nil)
                let types = [AVMetadataObjectTypeEAN13Code,
                    AVMetadataObjectTypeEAN8Code,
                    AVMetadataObjectTypeCode128Code]
                print("\(types)")
                
                _output.setMetadataObjectsDelegate(self,queue:queue)
                _output.metadataObjectTypes = types
                
                _session.addInput(input)
                _session.addOutput(_output)
                
                _previewLayer = AVCaptureVideoPreviewLayer(session: _session)
                _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.view.layer.addSublayer(_previewLayer)
                
                /*
                let maskColor = UIColor(red:0, green:0, blue:0, alpha:0.5)
                _tlMask.backgroundColor = maskColor
                _trMask.backgroundColor = maskColor
                _blMask.backgroundColor = maskColor
                _brMask.backgroundColor = maskColor
                
                let barColor = UIColor.whiteColor()
                _tlhBar.backgroundColor = barColor
                _tlvBar.backgroundColor = barColor
                _trhBar.backgroundColor = barColor
                _trvBar.backgroundColor = barColor
                _blhBar.backgroundColor = barColor
                _blvBar.backgroundColor = barColor
                _blhBar.backgroundColor = barColor
                _blvBar.backgroundColor = barColor
                
                self.view.addSubview(_tlMask)
                self.view.addSubview(_trMask)
                self.view.addSubview(_blMask)
                self.view.addSubview(_brMask)
                self.view.addSubview(_tlhBar)
                self.view.addSubview(_tlvBar)
                self.view.addSubview(_trhBar)
                self.view.addSubview(_trvBar)
                self.view.addSubview(_blhBar)
                self.view.addSubview(_blvBar)
                self.view.addSubview(_brhBar)
                self.view.addSubview(_brvBar)
                */
                
                break;
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        _session.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        _session.stopRunning()
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        _previewLayer.frame = self.view.bounds;
        
        /*
        let viewWidth = self.view.frame.size.width
        let viewHeight = self.view.frame.size.height
        _previewLayer.frame = self.view.bounds;
        
        if _codeMode == 2
        {
            let isIPad = UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad
            let scanWidth = isIPad ? 300 : 150;
            let scanHeight = isIPad ? 300 : 150;
            let scanTop = isIPad ? 200 : 100;
        }
        */
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects: [AnyObject]!, from
        connection: AVCaptureConnection!)
    {
        for obj in metadataObjects
        {
            let codeObj = obj as! AVMetadataMachineReadableCodeObject
            if codeObj.stringValue.characters.count > 0
            {
                print("the code is: \(codeObj.stringValue)")
            }
        }
    }
}

