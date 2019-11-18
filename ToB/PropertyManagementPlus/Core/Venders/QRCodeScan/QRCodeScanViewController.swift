//
//  QRCodeScanViewController.swift
//  SwiftDemo
//
//  Created by 郑文明 on 15/12/3.
//  Copyright © 2015年 郑文明. All rights reserved.
//

import UIKit
import AVFoundation

/// 扫描容器
var customContainerView: UIView!
/// 冲击波视图
var scanLineView: UIImageView!
///框
var borderIV: UIImageView!

enum ScanType {
    case equipmentPatrol
    case inoutScan
    case safeCheck
}

protocol ScanResultDelegate: class {
    func scan(result: String)
}

class QRCodeScanViewController: BaseViewController,AVCaptureMetadataOutputObjectsDelegate{
    
    var scanType = ScanType.equipmentPatrol
    open weak var scanDelegate: ScanResultDelegate?
    var isScan: Bool = false
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "扫一扫"
        setUpUI()
        
        startAnimation()

    }

    private func setUpUI(){
        
        self.view.backgroundColor = UIColor.white
        
        customContainerView = UIView(frame: CGRect(x:0, y:0, width:kScreenWidth-100, height:kScreenWidth-100))
        customContainerView.center = self.view.center;
        customContainerView.clipsToBounds = true
        view.addSubview(customContainerView)
        
        borderIV = UIImageView(frame: customContainerView.frame)
        borderIV.image = UIImage(named: "codeframe")
        borderIV.clipsToBounds = true
        view.addSubview(borderIV)
        
        scanLineView = UIImageView(frame:CGRect(x:0, y:0-customContainerView.frame.size.height, width:customContainerView.frame.size.width, height:customContainerView.frame.size.height))

        scanLineView.image = UIImage(named: "qrcode_scanline_qrcode")
        borderIV.addSubview(scanLineView)
        
        
        scanQRCode()
    }
    // MARK: - 内部控制方法
    private func scanQRCode()
    {
        guard let input = input else {
            return
        }
        // 1.判断输入能否添加到会话中
        if !session.canAddInput(input)
        {
            return
        }
        // 2.判断输出能够添加到会话中
        if !session.canAddOutput(output)
        {
            return
        }
        // 3.添加输入和输出到会话中
        session.addInput(input)
        session.addOutput(output)
        
        // 4.设置输出能够解析的数据类型
        // 注意点: 设置数据类型一定要在输出对象添加到会话之后才能设置
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // 5.设置监听监听输出解析到的数据
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        // 6.添加预览图层
        view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.frame = view.bounds
        
        // 7.添加容器图层
        view.layer.addSublayer(containerLayer)
        containerLayer.frame = view.bounds
        
        // 8.开始扫描
        session.startRunning()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    func startAnimation()
    {
        
        // 2.执行扫描动画
        UIView.animate(withDuration: 1.5) { () -> Void in
            
            UIView.setAnimationRepeatCount(MAXFLOAT)
            
            scanLineView.frame = CGRect(x:scanLineView.frame.origin.x, y:scanLineView.frame.origin.y+customContainerView.frame.size.height+100, width:scanLineView.frame.size.width, height:scanLineView.frame.size.height)
            
        }
        
    }
    
    // MARK: - 懒加载
    private lazy var input: AVCaptureDeviceInput? = {
        let device = AVCaptureDevice.default(for: AVMediaType.video)
        if device != nil {
            return try? AVCaptureDeviceInput(device: device!)
        }
        return nil
    }()
    
    private lazy var session:AVCaptureSession = AVCaptureSession()
    
    private lazy var output:AVCaptureMetadataOutput = {
        let out = AVCaptureMetadataOutput()
        let viewRect = self.view.frame
        let containerRect = customContainerView.frame;
        let x = containerRect.origin.y / viewRect.height;
        let y = containerRect.origin.x / viewRect.width;
        let width = containerRect.height / viewRect.height;
        let height = containerRect.width / viewRect.width;

        out.rectOfInterest = CGRect(x: x, y: y, width: width, height: height)
        
        return out
    }()

     lazy var containerLayer:CALayer = CALayer()
    
    /// 预览图层
     lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if isScan {
            return
        }
        
        isScan = true
        
        // 1.显示结果
        print(metadataObjects.last)
        
        if (scanType == .inoutScan
            || scanType == .equipmentPatrol
            || scanType == .safeCheck) {
            self.navigationController?.popViewController(animated: true)
        }
        
        scanDelegate?.scan(result: ((metadataObjects.last as! AVMetadataMachineReadableCodeObject).stringValue) as! String)
    }

}

extension QRCodeScanViewController: UITabBarDelegate
{
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // 根据当前选中的按钮重新设置二维码容器高度
        
        UIView.animate(withDuration: 0.5) { () -> Void in
            borderIV.frame = customContainerView.frame
            borderIV.center = self.view.center;
            scanLineView.image = UIImage(named: "qrcode_scanline_qrcode")
            
        }
        
    }
}
