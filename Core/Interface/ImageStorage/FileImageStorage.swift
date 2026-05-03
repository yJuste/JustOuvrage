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
	private let cache = NSCache<NSString, UIImage>()
	
	func save(image: UIImage) throws -> String {
		
		let file = UUID().uuidString + ".png"
		guard let data = image.pngData() else { throw Errors.ImageError }
		
		try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
		try data.write(to: folder.appendingPathComponent(file))
		
		cache.setObject(image, forKey: file as NSString)
		
		return file
	}
	
	func load(image: String) throws -> UIImage {
		
		if let cached = cache.object(forKey: image as NSString) { return cached }
		
		let data = try Data(contentsOf: folder.appendingPathComponent(image))
		guard let final = UIImage(data: data) else { throw Errors.ImageError }
		
		cache.setObject(final, forKey: image as NSString)
		
		return final
	}
	
	func delete(image: String) throws {
		
		try FileManager.default.removeItem(at: folder.appendingPathComponent(image))
		
		cache.removeObject(forKey: image as NSString)
	}
}
