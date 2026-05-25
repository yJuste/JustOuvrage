//
//  Theme.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/25/26.
//

import SwiftUI

enum Theme {
	
	static func gradientColors(from image: UIImage) -> [Color] {
		
		guard let cgImage = image.cgImage else { return [.black, .black] }
		
		let width = 60
		let height = 60
		let bytesPerPixel = 4
		let bytesPerRow = bytesPerPixel * width
		
		var rawData = [UInt8](repeating: 0, count: width * height * 4)
		
		guard let context = CGContext(data: &rawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return [.black, .black] }
		
		context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		
		var totalR: CGFloat = 0
		var totalG: CGFloat = 0
		var totalB: CGFloat = 0
		var totalSaturation: CGFloat = 0
		var pixelCount: CGFloat = 0
		
		for i in stride(from: 0, to: rawData.count, by: 4) {
			
			let r = CGFloat(rawData[i]) / 255
			let g = CGFloat(rawData[i + 1]) / 255
			let b = CGFloat(rawData[i + 2]) / 255
			let color = UIColor(red: r, green: g, blue: b, alpha: 1)
			var h: CGFloat = 0
			var s: CGFloat = 0
			var br: CGFloat = 0
			
			color.getHue(&h, saturation: &s, brightness: &br, alpha: nil)
			totalR += r
			totalG += g
			totalB += b
			totalSaturation += s
			pixelCount += 1
		}
		
		guard pixelCount > 0 else { return [.black, .black] }
		
		let avgColor = UIColor(red: totalR / pixelCount, green: totalG / pixelCount, blue: totalB / pixelCount, alpha: 1)
		let avgSaturation = totalSaturation / pixelCount
		
		var h: CGFloat = 0
		var s: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		avgColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
		b = min(max(b, 0.22), 0.72)
		
		if avgSaturation < 0.12 {
			
			let darkGray = UIColor(hue: h, saturation: 0, brightness: max(b - 0.18, 0.18), alpha: 1)
			let lightGray = UIColor(hue: h, saturation: 0, brightness: min(b - 0.05, 0.45), alpha: 1)
			
			return [Color(uiColor: darkGray), Color(uiColor: lightGray)]
		}
		
		let color1 = UIColor(hue: h - 0.025, saturation: min(s + 0.06, 1), brightness: max(b - 0.14, 0), alpha: 1)
		let color2 = UIColor(hue: h + 0.02, saturation: max(s - 0.03, 0), brightness: min(b + 0.04, 1), alpha: 1)
		
		return [Color(uiColor: color1), Color(uiColor: color2)]
	}
}
