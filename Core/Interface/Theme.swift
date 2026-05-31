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
		
		let width = 80
		let height = 80
		
		var rawData = [UInt8](repeating: 0, count: width * height * 4)
		
		guard let context = CGContext(data: &rawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return [.black, .black] }
		
		context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
		
		struct Bucket {
			
			var r: CGFloat = 0
			var g: CGFloat = 0
			var b: CGFloat = 0
			var count: CGFloat = 0
		}
		
		var buckets: [Int: Bucket] = [:]
		
		for i in stride(from: 0, to: rawData.count, by: 4) {
			
			let r = CGFloat(rawData[i]) / 255
			let g = CGFloat(rawData[i + 1]) / 255
			let b = CGFloat(rawData[i + 2]) / 255
			var h: CGFloat = 0
			var s: CGFloat = 0
			var br: CGFloat = 0
			
			UIColor(red: r, green: g, blue: b, alpha: 1).getHue(&h, saturation: &s, brightness: &br, alpha: nil)
			
			if s < 0.15 || br < 0.12 { continue }
			
			let bucketIndex = Int(h * 12)
			var bucket = buckets[bucketIndex] ?? Bucket()
			
			bucket.r += r
			bucket.g += g
			bucket.b += b
			bucket.count += 1
			buckets[bucketIndex] = bucket
		}
		
		var uiColors: [UIColor] = []
		
		for bucket in (buckets.values.sorted { $0.count > $1.count }.prefix(2)) {
			
			let count = bucket.count
			
			guard count > 0 else { continue }
			
			uiColors.append(UIColor(red: bucket.r / count, green: bucket.g / count, blue: bucket.b / count, alpha: 1))
		}
		
		while uiColors.count < 2 {
			uiColors.append(uiColors.first ?? .black)
		}
		
		uiColors.sort { c1, c2 in
			var b1: CGFloat = 0
			var b2: CGFloat = 0
			c1.getHue(nil, saturation: nil, brightness: &b1, alpha: nil)
			c2.getHue(nil, saturation: nil, brightness: &b2, alpha: nil)
			return b1 < b2
		}
		return uiColors.map { Color(uiColor: $0) }
	}
}
