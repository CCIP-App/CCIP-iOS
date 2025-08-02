//
//  QRCodeGenerator.swift
//  OPass
//
//  Created by Brian Chang on 2025/8/2.
//  2025 OPass.
//

import Foundation
import UIKit
import CoreImage
import CoreGraphics
import SwiftUI

public enum QRCodeIcon {
    case none
    case cutout
    case custom(UIImage?)
}

public enum QRCodeErrorCorrectionLevel: String {
    case low = "L"
    case medium = "M"
    case quartile = "Q"
    case high = "H"
}

private func floorToContextPixels(_ value: CGFloat, scale: CGFloat = UIScreen.main.scale) -> CGFloat {
    return floor(value * scale) / scale
}

private func roundToContextPixels(_ value: CGFloat, scale: CGFloat = UIScreen.main.scale) -> CGFloat {
    return round(value * scale) / scale
}

public func qrCodeCutout(size: Int, dimensions: CGSize, scale: CGFloat = UIScreen.main.scale) -> (Int, CGRect, CGFloat) {
    var cutoutSize = Int(round(CGFloat(size) * 0.297))
    if size == 39 {
        cutoutSize = 11
    } else if cutoutSize % 2 == 0 {
        cutoutSize += 1
    }
    cutoutSize = min(23, cutoutSize)
    
    let quadSize = floorToContextPixels(dimensions.width / CGFloat(size), scale: scale)
    let cutoutSide = quadSize * CGFloat(cutoutSize - 2)
    let cutoutRect = CGRect(
        x: floorToContextPixels((dimensions.width - cutoutSide) / 2.0, scale: scale),
        y: floorToContextPixels((dimensions.height - cutoutSide) / 2.0, scale: scale),
        width: cutoutSide,
        height: cutoutSide
    )
    
    return (cutoutSize, cutoutRect, quadSize)
}

public func generateQRCode(
    string: String,
    size: CGFloat,
    color: UIColor = .black,
    backgroundColor: UIColor? = nil,
    icon: QRCodeIcon = .none,
    ecl: QRCodeErrorCorrectionLevel = .low,
    onlyMarkers: Bool = false
) -> UIImage? {
    guard let data = string.data(using: .isoLatin1, allowLossyConversion: false),
          let filter = CIFilter(name: "CIQRCodeGenerator") else {
        return nil
    }
    
    filter.setValue(data, forKey: "inputMessage")
    filter.setValue(ecl.rawValue, forKey: "inputCorrectionLevel")
    
    guard let output = filter.outputImage else { return nil }
    
    let qrSize = Int(output.extent.width)
    let bytesPerRow = Int(qrSize) * 4
    let length = bytesPerRow * qrSize
    
    guard let bytes = malloc(length)?.assumingMemoryBound(to: UInt8.self) else {
        return nil
    }
    
    defer { free(bytes) }
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.noneSkipFirst.rawValue)
    
    guard let context = CGContext(
        data: bytes,
        width: qrSize,
        height: qrSize,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: colorSpace,
        bitmapInfo: bitmapInfo.rawValue
    ) else {
        return nil
    }
    
    let ciContext = CIContext(cgContext: context, options: nil)
    ciContext.draw(output, in: CGRect(x: 0, y: 0, width: qrSize, height: qrSize), from: output.extent)
    
    let qrData = Data(bytes: bytes, count: length)
    
    return generateStyledQRCode(
        qrData: qrData,
        qrSize: qrSize,
        bytesPerRow: bytesPerRow,
        targetSize: .init(width: size, height: size),
        color: color,
        backgroundColor: backgroundColor,
        icon: icon,
        onlyMarkers: onlyMarkers
    )
}

private func generateStyledQRCode(
    qrData: Data,
    qrSize: Int,
    bytesPerRow: Int,
    targetSize: CGSize,
    color: UIColor,
    backgroundColor: UIColor?,
    icon: QRCodeIcon,
    onlyMarkers: Bool
) -> UIImage? {
    let scale = UIScreen.main.scale
    
    UIGraphicsBeginImageContextWithOptions(targetSize, backgroundColor != nil, scale)
    guard let context = UIGraphicsGetCurrentContext() else {
        UIGraphicsEndImageContext()
        return nil
    }
    
    let (cutoutSize, clipRect, side) = qrCodeCutout(size: qrSize, dimensions: targetSize, scale: scale)
    let padding = roundToContextPixels((targetSize.width - CGFloat(side * CGFloat(qrSize))) / 2.0, scale: scale)
    
    let cutout: (Int, Int)?
    if case .none = icon {
        cutout = nil
    } else {
        let start = (qrSize - cutoutSize) / 2
        cutout = (start, start + cutoutSize - 1)
    }
    
    func valueAt(x: Int, y: Int) -> Bool {
        guard x >= 0 && x < qrSize && y >= 0 && y < qrSize else { return false }
        
        if let cutout = cutout, x > cutout.0 && x < cutout.1 && y > cutout.0 && y < cutout.1 {
            return false
        }
        
        return qrData.withUnsafeBytes { bytes in
            let offset = y * bytesPerRow + x * 4
            guard offset < qrData.count else { return false }
            let byteValue = bytes.bindMemory(to: UInt8.self)[offset]
            return byteValue < 255
        }
    }
    
    if let backgroundColor = backgroundColor {
        context.setFillColor(backgroundColor.cgColor)
        context.fill(CGRect(origin: .zero, size: targetSize))
    }
    
    var markerSize = 0
    for i in 1..<qrSize {
        if !valueAt(x: i, y: 1) {
            markerSize = i - 1
            break
        }
    }
    
    context.setFillColor(color.cgColor)
    
    if !onlyMarkers {
        // Pre-calculate template shapes for better performance
        let squareSize = side
        let outerRadius = squareSize / 3.0
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: squareSize * 4.0, height: squareSize), false, scale)
        guard let tmpContext = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // Fill rounded square template
        if let backgroundColor = backgroundColor {
            tmpContext.setFillColor(backgroundColor.cgColor)
            tmpContext.fill(CGRect(origin: CGPoint(), size: CGSize(width: squareSize, height: squareSize)))
        }
        tmpContext.setFillColor(color.cgColor)
        
        let roundedPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(), size: CGSize(width: squareSize, height: squareSize)), cornerRadius: outerRadius)
        tmpContext.addPath(roundedPath.cgPath)
        tmpContext.fillPath()

        // Square template (no rounding)
        tmpContext.fill(CGRect(origin: CGPoint(x: squareSize * 2.0, y: 0.0), size: CGSize(width: squareSize, height: squareSize)))
        
        // Inner cutout template
        tmpContext.fill(CGRect(origin: CGPoint(x: squareSize, y: 0.0), size: CGSize(width: squareSize, height: squareSize)))
        if let backgroundColor = backgroundColor {
            tmpContext.setFillColor(backgroundColor.cgColor)
        } else {
            tmpContext.setBlendMode(.clear)
        }
        
        let innerRadius = squareSize / 4.0
        let innerPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: squareSize, y: 0.0), size: CGSize(width: squareSize, height: squareSize)), cornerRadius: innerRadius)
        tmpContext.addPath(innerPath.cgPath)
        tmpContext.fillPath()
        
        // Square cutout template
        tmpContext.fill(CGRect(origin: CGPoint(x: squareSize * 3.0, y: 0.0), size: CGSize(width: squareSize, height: squareSize)))
        
        UIGraphicsEndImageContext()
        
        // Draw modules with proper corner logic
        for y in 0..<qrSize {
            for x in 0..<qrSize {
                let isMarkerRegion = (y < markerSize + 1 && (x < markerSize + 1 || x > qrSize - markerSize - 2)) ||
                                   (y > qrSize - markerSize - 2 && x < markerSize + 1)
                
                if isMarkerRegion { continue }
                
                if valueAt(x: x, y: y) {
                    let rect = CGRect(
                        x: padding + CGFloat(x) * squareSize,
                        y: padding + CGFloat(y) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    
                    var corners: UIRectCorner = .allCorners
                    
                    // Remove corners where adjacent modules connect
                    if valueAt(x: x, y: y - 1) {
                        corners.remove(.topLeft)
                        corners.remove(.topRight)
                    }
                    if valueAt(x: x, y: y + 1) {
                        corners.remove(.bottomLeft)
                        corners.remove(.bottomRight)
                    }
                    if valueAt(x: x - 1, y: y) {
                        corners.remove(.topLeft)
                        corners.remove(.bottomLeft)
                    }
                    if valueAt(x: x + 1, y: y) {
                        corners.remove(.topRight)
                        corners.remove(.bottomRight)
                    }
                    
                    if corners == .allCorners {
                        // Fully rounded module
                        let path = UIBezierPath(roundedRect: rect, cornerRadius: outerRadius)
                        context.addPath(path.cgPath)
                        context.fillPath()
                    } else if corners.isEmpty {
                        // Square module (fully connected)
                        context.fill(rect)
                    } else {
                        // Partially rounded module
                        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: outerRadius, height: outerRadius))
                        context.addPath(path.cgPath)
                        context.fillPath()
                    }
                } else {
                    // Draw inner corners for smooth connections
                    var innerCorners: UIRectCorner = []
                    
                    if valueAt(x: x - 1, y: y - 1) && valueAt(x: x - 1, y: y) && valueAt(x: x, y: y - 1) {
                        innerCorners.insert(.topLeft)
                    }
                    if valueAt(x: x + 1, y: y - 1) && valueAt(x: x + 1, y: y) && valueAt(x: x, y: y - 1) {
                        innerCorners.insert(.topRight)
                    }
                    if valueAt(x: x - 1, y: y + 1) && valueAt(x: x - 1, y: y) && valueAt(x: x, y: y + 1) {
                        innerCorners.insert(.bottomLeft)
                    }
                    if valueAt(x: x + 1, y: y + 1) && valueAt(x: x + 1, y: y) && valueAt(x: x, y: y + 1) {
                        innerCorners.insert(.bottomRight)
                    }
                    
                    if !innerCorners.isEmpty {
                        let rect = CGRect(
                            x: padding + CGFloat(x) * squareSize,
                            y: padding + CGFloat(y) * squareSize,
                            width: squareSize,
                            height: squareSize
                        )
                        
                        context.saveGState()
                        if let backgroundColor = backgroundColor {
                            context.setFillColor(backgroundColor.cgColor)
                        } else {
                            context.setBlendMode(.clear)
                        }
                        
                        let innerPath = UIBezierPath(roundedRect: rect, byRoundingCorners: innerCorners, cornerRadii: CGSize(width: innerRadius, height: innerRadius))
                        context.addPath(innerPath.cgPath)
                        context.fillPath()
                        
                        context.restoreGState()
                    }
                }
            }
        }
    }
    
    context.translateBy(x: padding, y: padding)
    
    context.setLineWidth(side)
    context.setStrokeColor(color.cgColor)
    
    let markerSide = floorToContextPixels(CGFloat(markerSize - 1) * side * 1.05, scale: scale)
    
    func drawMarker(x: CGFloat, y: CGFloat) {
        let outerRect = CGRect(
            x: x + side / 2.0,
            y: y + side / 2.0,
            width: markerSide,
            height: markerSide
        )
        let outerPath = UIBezierPath(roundedRect: outerRect, cornerRadius: markerSide / 3.5)
        context.addPath(outerPath.cgPath)
        context.strokePath()
        
        let dotSide = markerSide - side * 3.0
        let dotRect = CGRect(
            x: x + side * 2.0,
            y: y + side * 2.0,
            width: dotSide,
            height: dotSide
        )
        let dotPath = UIBezierPath(roundedRect: dotRect, cornerRadius: dotSide / 3.5)
        context.addPath(dotPath.cgPath)
        context.fillPath()
    }
    
    drawMarker(x: side, y: side)
    drawMarker(x: CGFloat(qrSize - 2) * side - markerSide, y: side)
    drawMarker(x: side, y: CGFloat(qrSize - 2) * side - markerSide)
    
    context.translateBy(x: -padding, y: -padding)
    
    switch icon {
    case let .custom(image):
        if let image = image {
            drawCustomIcon(in: context, rect: clipRect, image: image)
        }
    case .cutout, .none:
        break
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
}

private func drawCustomIcon(in context: CGContext, rect: CGRect, image: UIImage) {
    let imageSize = image.size
    let aspectRatio = imageSize.width / imageSize.height
    let rectAspectRatio = rect.width / rect.height
    
    var drawRect: CGRect
    if aspectRatio > rectAspectRatio {
        let height = rect.width / aspectRatio
        drawRect = CGRect(x: rect.minX, y: rect.midY - height / 2, width: rect.width, height: height)
    } else {
        let width = rect.height * aspectRatio
        drawRect = CGRect(x: rect.midX - width / 2, y: rect.minY, width: width, height: rect.height)
    }
    
    context.saveGState()
    context.translateBy(x: drawRect.midX, y: drawRect.midY)
    context.scaleBy(x: 1.0, y: -1.0)
    context.translateBy(x: -drawRect.midX, y: -drawRect.midY)
    
    if let cgImage = image.cgImage {
        context.draw(cgImage, in: drawRect)
    }
    
    context.restoreGState()
}
