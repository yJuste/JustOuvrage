//
//  FileImageStorage.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/23/26.
//

import SwiftUI

/// An Interface that handles local file image storage within the App Sandbox ( -> Documents/Image ).
/// External Dependencies: Constants, Errors
@Observable
final class FileImageStorage: ImageStorageService {
	
	let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Images")
	
	func save(image: UIImage) throws -> String {
		
		let file = UUID().uuidString + ".png"
		guard let data = image.pngData() else { throw Errors.ImageError }
		
		try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
		try data.write(to: folder.appendingPathComponent(file))
		
		return file
	}
	
	func load(image: String) throws -> UIImage {
		
		let data = try Data(contentsOf: folder.appendingPathComponent(image))
		guard let final = UIImage(data: data) else { throw Errors.ImageError }
		return final
	}
	
	func delete(image: String) throws {
		
		try FileManager.default.removeItem(at: folder.appendingPathComponent(image))
	}
}
