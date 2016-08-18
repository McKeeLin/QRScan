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
    var _player: AVAudioPlayer?
    
    //建立的SystemSoundID对象
    var soundID:SystemSoundID = 0
    
    var _codeMode: Int = 2
    
    
    @IBOutlet var _button: UIButton?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //获取声音地址
        let path = NSBundle.mainBundle().pathForResource("audio/beep", ofType: "wav")
        
        //地址转换
        //let baseURL = NSURL(fileURLWithPath: path!)
        
        //赋值
        //AudioServicesCreateSystemSoundID(baseURL, &soundID)
        
        //*
        let soundData = NSData(contentsOfFile: path!)
        
        do
        {
            _player = try AVAudioPlayer(data: soundData!)
        }
        catch
        {
            return
        }
        //*/
        
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
        NSLog("....1")
        for obj in metadataObjects
        {
            let codeObj = obj as! AVMetadataMachineReadableCodeObject
            var code = codeObj.stringValue!
            if code.characters.count > 0
            {
                NSLog("....11")
                //播放声音
                //_player!.play()
                //AudioServicesPlaySystemSound(soundID)
                
                NSLog("the code is:%@", code)
                
                _session.stopRunning()
                _button!.selected = true
                
                NSLog("....2")
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
                NSLog("....3")
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

