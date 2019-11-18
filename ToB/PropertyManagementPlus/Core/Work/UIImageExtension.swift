//
//  UIImageExtension.swift
//  PropertyManagementPlus
//
//  Created by Mac on 2017/11/16.
//  Copyright © 2017年 Lesoft. All rights reserved.
//

import Foundation

extension UIImage{
    
    //水印位置枚举
    enum WaterMarkCorner{
        case TopLeft
        case TopRight
        case BottomLeft
        case BottomRight
    }
    
    //添加水印方法
    func waterMarkedImage(waterMarkText: String, corner: WaterMarkCorner = .BottomRight,
                          margin: CGPoint = CGPoint(x: 20, y: 20),
                          waterMarkTextColor: UIColor = UIColor.white,
                          waterMarkTextFont: UIFont = UIFont.systemFont(ofSize: 20),
                          backgroundColor: UIColor = UIColor.clear) -> UIImage {
        
        let textAttributes = [NSAttributedStringKey.foregroundColor: waterMarkTextColor,
                              NSAttributedStringKey.font: waterMarkTextFont,
                              NSAttributedStringKey.backgroundColor: backgroundColor]
        let textSize = NSString(string: waterMarkText).size(withAttributes: textAttributes)
        var textFrame = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
        
        let imageSize = self.size
        switch corner{
        case .TopLeft:
            textFrame.origin = margin
        case .TopRight:
            textFrame.origin = CGPoint(x: imageSize.width - textSize.width - margin.x, y: margin.y)
        case .BottomLeft:
            textFrame.origin = CGPoint(x: margin.x, y: imageSize.height - textSize.height - margin.y)
        case .BottomRight:
            textFrame.origin = CGPoint(x: imageSize.width - textSize.width - margin.x,
                                       y: imageSize.height - textSize.height - margin.y)
        }
        
        // 开始给图片添加文字水印
        UIGraphicsBeginImageContext(imageSize)
        self.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        NSString(string: waterMarkText).draw(in: textFrame, withAttributes: textAttributes)
        
        let waterMarkedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return waterMarkedImage!
    }
    
    //添加图片水印方法
    func waterMarkedImage(waterMarkImage:UIImage, corner:WaterMarkCorner = .BottomRight,
                          margin:CGPoint = CGPoint(x: 20, y: 20), alpha:CGFloat = 1) -> UIImage{
        
        var markFrame = CGRect(x: 0, y: 0, width: waterMarkImage.size.width, height: waterMarkImage.size.height)
        let imageSize = self.size
        
        switch corner{
        case .TopLeft:
            markFrame.origin = margin
        case .TopRight:
            markFrame.origin = CGPoint(x: imageSize.width - waterMarkImage.size.width - margin.x,
                                       y: margin.y)
        case .BottomLeft:
            markFrame.origin = CGPoint(x: margin.x,
                                       y: imageSize.height - waterMarkImage.size.height - margin.y)
        case .BottomRight:
            markFrame.origin = CGPoint(x: imageSize.width - waterMarkImage.size.width - margin.x,
                                       y: imageSize.height - waterMarkImage.size.height - margin.y)
        }
        
        // 开始给图片添加图片
        UIGraphicsBeginImageContext(imageSize)
        self.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        waterMarkImage.draw(in: markFrame, blendMode: .normal, alpha: alpha)
        let waterMarkedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return waterMarkedImage!
    }
}
