//
//  ViewController.swift
//  QRScan
//
//  Created by McKee on 16/8/11.
//  Copyright © 2016年 MCKEELIN. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox


class ViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate {

    var _camera: AVCaptureDevice?
    var _session = AVCaptureSession()
    var _previewLayer = AVCaptureVideoPreviewLayer()
    var _output = AVCaptureMetadataOutput()
    
    //建立的SystemSoundID对象
    var soundID:SystemSoundID = 0
    
    @IBOutlet var _button: UIButton?
    
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
        
        //获取声音地址
        let path = NSBundle.mainBundle().pathForResource("qrcode_found", ofType: "wav")
        
        //地址转换
        let baseURL = NSURL(fileURLWithPath: path!)
        
        //赋值
        AudioServicesCreateSystemSoundID(baseURL, &soundID)
        
        _button!.selected = false
        let cameras = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for camera in cameras!
        {
            if camera.position == AVCaptureDevicePosition.Back
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
                
                _session.addInput(input)
                _session.addOutput(_output)
                
                
                let types = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,
                             AVMetadataObjectTypeEAN8Code,
                             AVMetadataObjectTypeCode128Code]
                print("\(types)")
                
                _output.setMetadataObjectsDelegate(self,queue:dispatch_get_main_queue())
                _output.metadataObjectTypes = types
                
                _previewLayer = AVCaptureVideoPreviewLayer(session: _session)
                _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.view.layer.addSublayer(_previewLayer)
                self.view.layer.insertSublayer(_previewLayer, below:_button!.layer)
                
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
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear(animated)
        _session.startRunning()
    }
    
    override func viewWillDisappear(animated: Bool)
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
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation)
    {
        let connection = _previewLayer.connection!
        if( connection.supportsVideoOrientation )
        {
            let statusBarOrientation = UIApplication.sharedApplication().statusBarOrientation
            var layerOrientation = AVCaptureVideoOrientation.Portrait
            switch statusBarOrientation
            {
            case UIInterfaceOrientation.Portrait:
                layerOrientation = AVCaptureVideoOrientation.Portrait
                break
                
            case UIInterfaceOrientation.PortraitUpsideDown:
                layerOrientation = AVCaptureVideoOrientation.PortraitUpsideDown
                break
                
            case UIInterfaceOrientation.LandscapeLeft:
                layerOrientation = AVCaptureVideoOrientation.LandscapeLeft
                break
                
            case UIInterfaceOrientation.LandscapeRight:
                layerOrientation = AVCaptureVideoOrientation.LandscapeRight
                break
                
            default:
                layerOrientation = AVCaptureVideoOrientation.Portrait
            }
            
            connection.videoOrientation = layerOrientation
        }
    }
    

    func captureOutput(captureOutput: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects: [AnyObject]!, from
        connection: AVCaptureConnection!)
    {
        print("....1")
        for obj in metadataObjects
        {
            let codeObj = obj as! AVMetadataMachineReadableCodeObject
            var code = codeObj.stringValue!
            if code.characters.count > 0
            {
                //播放声音
                AudioServicesPlaySystemSound(soundID)
                print("the code is: \(code)")
                
                _session.stopRunning()
                _button!.selected = true
                
                print("....2")
                let successAlert = UIAlertController(title:"抓取到的内容是:", message:code, preferredStyle: .Alert)
                successAlert.addAction(UIAlertAction(title:"关闭", style: .Default, handler: { (_) -> Void in
                }))
                successAlert.addAction(UIAlertAction(title:"复制", style: .Default, handler: { (_) -> Void in
                    let pastedboard = UIPasteboard.generalPasteboard()
                    pastedboard.string = code
                }))
                successAlert.addAction(UIAlertAction(title:"用Safari打开", style: .Default, handler: { (_) -> Void in
                    if (!code.hasPrefix("http://")) && (!code.hasPrefix("https://"))
                    {
                        code = "http://" + code
                    }
                    UIApplication.sharedApplication().openURL(NSURL(string: code)!)
                }))
                print("....3")
                self.presentViewController(successAlert, animated: true, completion: nil)
                
            }
        }
    }
    
    @IBAction func onTouchButton(button: UIButton)
    {
        if( button.selected == false )
        {
            _session.stopRunning()
            button.selected = true;
        }
        else
        {
            _session.startRunning()
            button.selected = false
        }
    }
    
}

