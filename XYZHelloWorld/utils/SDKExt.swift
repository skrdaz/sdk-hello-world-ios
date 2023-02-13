//
//  SDKExt.swift
//  nhworld
//
//  Created by Admin on 23/01/23.
//

import Foundation
import UIKit
import Alamofire

/**
 required Alamofire
 */
extension String: ParameterEncoding {

    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }

}

extension Data {

        private static let regex = try! NSRegularExpression(pattern: "([0-9a-fA-F]{2})", options: [])
        
        /// Create instance from string with hex numbers.
        init(fromHex: String) {
            let range = NSRange(location: 0, length: fromHex.utf16.count)
            let bytes = Self.regex.matches(in: fromHex, options: [], range: range)
                .compactMap { Range($0.range(at: 1), in: fromHex) }
                .compactMap { UInt8(fromHex[$0], radix: 16) }
            self.init(bytes)
        }
    
        func hexEncodedString() -> String {
            return map { String(format: "%02hhx", $0) }.joined()
        }
    
        
    
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
           let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
           let scanner = Scanner(string: hexString)
           if (hexString.hasPrefix("#")) {
               scanner.scanLocation = 1
           }
           var color: UInt32 = 0
           scanner.scanHexInt32(&color)
           let mask = 0x000000FF
           let r = Int(color >> 16) & mask
           let g = Int(color >> 8) & mask
           let b = Int(color) & mask
           let red   = CGFloat(r) / 255.0
           let green = CGFloat(g) / 255.0
           let blue  = CGFloat(b) / 255.0
           self.init(red:red, green:green, blue:blue, alpha:alpha)
       }
       func toHexString() -> String {
           var r:CGFloat = 0
           var g:CGFloat = 0
           var b:CGFloat = 0
           var a:CGFloat = 0
           getRed(&r, green: &g, blue: &b, alpha: &a)
           let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
           return String(format:"#%06x", rgb)
       }
}

extension UIImage {
    
    func flipHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        context.translateBy(x: self.size.width/2, y: self.size.height/2)
        context.scaleBy(x: -1.0, y: 1.0)
        context.translateBy(x: -self.size.width/2, y: -self.size.height/2)
        
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
            // Determine the scale factor that preserves aspect ratio
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            
            let scaleFactor = min(widthRatio, heightRatio)
            
            // Compute the new image size that preserves aspect ratio
            let scaledImageSize = CGSize(
                width: size.width * scaleFactor,
                height: size.height * scaleFactor
            )

            // Draw and return the resized UIImage
            let renderer = UIGraphicsImageRenderer(
                size: scaledImageSize
            )

            let scaledImage = renderer.image { _ in
                self.draw(in: CGRect(
                    origin: .zero,
                    size: scaledImageSize
                ))
            }
            
            return scaledImage
        }
}
