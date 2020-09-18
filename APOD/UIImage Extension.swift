//
//  UIImage Extension.swift
//  APOD WidgetExtension
//
//  Created by Izumu Mishima on 01/07/2020.
//

import UIKit

extension UIColor {
	var hsba:(h: CGFloat, s: CGFloat,b: CGFloat,a: CGFloat) {
		var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
		self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
		return (h: h, s: s, b: b, a: a)
	}
}

extension CGImage {
	func colors(at: [CGPoint]) -> [UIColor]? {
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bytesPerPixel = 4
		let bytesPerRow = bytesPerPixel * width
		let bitsPerComponent = 8
		let bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
		
		guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo),
			  let ptr = context.data?.assumingMemoryBound(to: UInt8.self) else {
			return nil
		}
		
		context.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
		
		return at.map { p in
			let i = bytesPerRow * Int(p.y) + bytesPerPixel * Int(p.x)
			
			let a = CGFloat(ptr[i + 3]) / 255.0
			let r = (CGFloat(ptr[i]) / a) / 255.0
			let g = (CGFloat(ptr[i + 1]) / a) / 255.0
			let b = (CGFloat(ptr[i + 2]) / a) / 255.0
			
			return UIColor(red: r, green: g, blue: b, alpha: a)
		}
	}
}

extension UIImage {
	
	func resized(to size: CGSize) -> UIImage? {
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { (context) in
			self.draw(in: CGRect(origin: .zero, size: size))
		}
	}
	 
	var averageColor: UIColor? {
		guard let small = self.resized(to: CGSize(width: 1, height: 1)) else { return nil }
		
		return small.cgImage?.colors(at: [.zero])?[0]
	}
	
	var averageRGBA: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
		guard let averageCol = averageColor else { return nil }
		
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		
		averageCol.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
		
		return (red, green, blue, alpha)
	}
	
	var averageBrightness: CGFloat? {
		let (red, green, blue, _) = averageRGBA ?? (1, 1, 1, 1)
		let weightedRed = red
		let weightedGreen = green * 1.2
		let weightedBlue = blue * 0.8
		
		return (weightedRed + weightedGreen + weightedBlue) / 3
//		return averageColor?.hsba.b
		
	}
}
