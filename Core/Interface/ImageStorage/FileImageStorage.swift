//
//  FileImageStorage.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/23/26.
//

import SwiftUI

// MARK: When VIewModel will be added, Use Data over UIImage

/// An Interface that handles `local file image storage` within the App Sandbox ( -> Documents/Image ).
/// Handles `file storage cache` as well.
/// External Dependencies: Constants, Errors
@Observable final class FileImageStorage: ImageStorageService {
	
	private let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Images")
	private let cache: NSCache<NSString, UIImage> = {
		let c = NSCache<NSString, UIImage>()
		c.countLimit = 50
		c.totalCostLimit = 100 * 1024 * 1024
		return c
	}()
	
	func save(image: UIImage) throws -> String {
		
		let file = UUID().uuidString + ".png"
		guard let data = image.pngData() else { throw Errors.ImageError }
		
		try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
		try data.write(to: folder.appendingPathComponent(file))
		
		cache.setObject(image, forKey: file as NSString)
		
		return file
	}
	
	func load(image name: String) throws -> UIImage {
		
		if name == Constants.defaultDeckImage {
			throw Errors.ImageError
		}
		
		if let cached = cache.object(forKey: name as NSString) {
			return cached
		}
		
		let url = folder.appendingPathComponent(name)
		
		guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
			throw Errors.ImageError
		}
		
		let options: [CFString: Any] = [
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceThumbnailMaxPixelSize: 1024,
			kCGImageSourceCreateThumbnailWithTransform: true
		]
		
		guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
			throw Errors.ImageError
		}
		
		let final = UIImage(cgImage: cgImage)
		
		let cost = Int(final.size.width * final.size.height * 4)
		cache.setObject(final, forKey: name as NSString, cost: cost)
		
		return final
	}
	
	func load(image name: String, size: CGFloat) throws -> UIImage {
		
		if name == Constants.defaultDeckImage {
			throw Errors.ImageError
		}
		
		if let cached = cache.object(forKey: name as NSString) {
			return cached
		}
		
		let url = folder.appendingPathComponent(name)
		
		guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
			throw Errors.ImageError
		}
		
		let options: [CFString: Any] = [
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceThumbnailMaxPixelSize: size,
			kCGImageSourceCreateThumbnailWithTransform: true
		]
		
		guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
			throw Errors.ImageError
		}
		
		let final = UIImage(cgImage: cgImage)
		
		let cost = Int(final.size.width * final.size.height * 4)
		cache.setObject(final, forKey: name as NSString, cost: cost)
		
		return final
	}
	
	func delete(image: String) throws {
		
		try FileManager.default.removeItem(at: folder.appendingPathComponent(image))
		
		cache.removeObject(forKey: image as NSString)
	}
}
