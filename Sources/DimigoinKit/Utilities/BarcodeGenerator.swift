//
//  Barcode.swift
//  dimigoin
//
//  Created by 변경민 on 2021/02/25.
//  Copyright © 2021 seohun. All rights reserved.
//

import SwiftUI

public func generateBarcode(from string: String) -> UIImage? {
    let data = string.data(using: String.Encoding.ascii)

    if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
        filter.setDefaults()
        // Margin
        filter.setValue(data, forKey: "inputMessage")
        // Scaling
        let transform = CGAffineTransform(scaleX: 3, y: 3)

        if let output = filter.outputImage?.transformed(by: transform) {
            let context: CIContext = CIContext.init(options: nil)
            let cgImage: CGImage = context.createCGImage(output, from: output.extent)!
            let rawImage: UIImage = UIImage.init(cgImage: cgImage)

            // Refinement code to allow conversion to NSData or share UIImage. Code here:
            let cgimage: CGImage = (rawImage.cgImage)!
            let cropZone = CGRect(x: 0, y: 0, width: Int(rawImage.size.width), height: Int(rawImage.size.height))
            let cWidth: size_t  = size_t(cropZone.size.width)
            let cHeight: size_t  = size_t(cropZone.size.height)
            let bitsPerComponent: size_t = cgimage.bitsPerComponent
            // THE OPERATIONS ORDER COULD BE FLIPPED, ALTHOUGH, IT DOESN'T AFFECT THE RESULT
            let bytesPerRow = (cgimage.bytesPerRow) / (cgimage.width  * cWidth)

            let context2: CGContext = CGContext(data: nil, width: cWidth, height: cHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: cgimage.bitmapInfo.rawValue)!

            context2.draw(cgimage, in: cropZone)

            let result: CGImage  = context2.makeImage()!
            let finalImage = UIImage(cgImage: result)

            return finalImage
        }
    }
    return nil
}
