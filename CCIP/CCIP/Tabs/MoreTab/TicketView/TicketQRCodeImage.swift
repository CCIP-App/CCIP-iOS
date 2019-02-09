//
//  TicketQRCodeImage.swift
//  CCIP
//
//  Created by 腹黒い茶 on 2017/07/24.
//  Copyright © 2017年 CPRTeam. All rights reserved.
//

import Foundation
import EFQRCode

@objc public class TicketQRCodeImage : NSObject {
    @objc public class func generate(
        _ content: String,
        size: CGSize = CGSize(width: 300, height: 300),
        backgroundColor: CGColor = CGColor.EFWhite(),
        foregroundColor: CGColor = CGColor.EFBlack(),
        watermark: CGImage? = nil
        ) -> CGImage? {
        let generator = EFQRCodeGenerator(
            content: content,
            size: EFIntSize(width: NSInteger(size.width), height: NSInteger(size.height))
        );
        generator.setWatermark(watermark: watermark, mode: EFWatermarkMode.center)
        generator.setColors(backgroundColor: backgroundColor, foregroundColor: foregroundColor)
        generator.setInputCorrectionLevel(inputCorrectionLevel: .h)
        generator.setMagnification(magnification: EFIntSize(width: 100, height: 100))
        
        return generator.generate();
    }
}
