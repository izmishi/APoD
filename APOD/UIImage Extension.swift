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
	func colors(at points: [CGPoint]) -> [UIColor]? {
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
		
		return points.map { p in
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
	
//	func resized(to newSize: CGSize, scale: CGFloat = 1) -> UIImage? {
//		let format = UIGraphicsImageRendererFormat()
//		format.scale = scale
//		
//		let renderer = UIGraphicsImageRenderer(size: size, format: format)
//		
//		return renderer.image { (context) in
//			self.draw(in: CGRect(origin: .zero, size: size))
//		}
//	}
	
	func resized(to newSize: CGSize, scale: CGFloat = 1) -> UIImage? {
		NSLog("RESIZE: \(newSize)")
		
		let format = UIGraphicsImageRendererFormat()
		format.scale = scale
		
		let renderer = UIGraphicsImageRenderer(size: size, format: format)
		
		return renderer.image { (context) in
			self.draw(in: CGRect(origin: .zero, size: size))
		}
	}
	
	func resizeSmallestDimensionDown(to dim: CGFloat) -> UIImage? {
		let minDimension = min(size.width, size.height)
		// scale the smallest dimension down to dim if it's larger than 1.1 * dim
		
		guard minDimension > dim * 1.1 else {
			return self
		}
		
		let scale = minDimension / dim
		
		let newSize = CGSize(width: size.width / scale, height: size.height / scale)
		
		NSLog("scale: \(scale), \(newSize), \(self.size)")
		let r = resized(to: newSize)
		
		return r
	}
	
	var averageColorFromRandomSample: UIColor? {
		let count = 20
		
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		
		var avgRed: CGFloat = 0
		var avgGreen: CGFloat = 0
		var avgBlue: CGFloat = 0
		var avgAlpha: CGFloat = 0
		
		var randomPoints: [CGPoint] = []
		
		for _ in 0..<count {
			randomPoints.append(CGPoint(x: Int.random(in: 0..<Int(size.width)), y: Int.random(in: 0..<Int(size.height))))
		}
		
		guard let colours = self.cgImage?.colors(at: randomPoints) else { return nil }
		
		for colour in colours {
			colour.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
			
			avgRed += red
			avgBlue += blue
			avgGreen += green
			avgAlpha += alpha
		}
		
		let cgFloatCount = CGFloat(count)
		
		return UIColor(red: avgRed / cgFloatCount, green: avgGreen / cgFloatCount, blue: avgBlue / cgFloatCount, alpha: avgGreen / cgFloatCount)
	}
	 
	var averageColor: UIColor? {
		guard let small = self.resized(to: CGSize(width: 1, height: 1), scale: 0.01) else { return nil }
		
		
		NSLog("smallImage: \(small)")
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
