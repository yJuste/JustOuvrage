//
//  FileImageStorage.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/23/26.
//

import UIKit

// MARK: LOAD is cached but for only 1 size. Havec to change this.

/// An Interface that handles `local file image storage` within the App Sandbox ( -> Documents/Image ).
/// Handles `file storage cache` as well.
/// External Dependencies: Constants, Errors
@Observable final class FileImageStorage: ImageStorageService {
	
	private let folder: URL = {
		
		let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Images", isDirectory: true)
		try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		
		return url
	}()
	
	private let cache: NSCache<NSString, UIImage> = { return NSCache<NSString, UIImage>() }()
	
	func save(image: UIImage) throws -> String {
		
		let file = UUID().uuidString + ".png"
		
		guard let data = image.pngData() else { throw Errors.Image }
		
		try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
		try data.write(to: folder.appendingPathComponent(file))
		
		cache.setObject(try load(image: file), forKey: file as NSString)
		
		return file
	}
	
	func load(image name: String, size: CGFloat = 1024) throws -> UIImage {
		
		if name == Constants.defaultDeckImage || name == Constants.defaultProfileImage { throw Errors.Image }
		if let cached = cache.object(forKey: name as NSString) { return cached }
		
		guard let source = CGImageSourceCreateWithURL(folder.appendingPathComponent(name) as CFURL, nil) else { throw Errors.Image }
		guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, [kCGImageSourceCreateThumbnailFromImageAlways: true, kCGImageSourceThumbnailMaxPixelSize: size, kCGImageSourceCreateThumbnailWithTransform: true] as CFDictionary) else { throw Errors.Image }
		
		let final = UIImage(cgImage: cgImage)
		cache.setObject(final, forKey: name as NSString)
		
		return final
	}
	
	func delete(image: String) throws {
		try FileManager.default.removeItem(at: folder.appendingPathComponent(image))
		cache.removeObject(forKey: image as NSString)
	}
}
