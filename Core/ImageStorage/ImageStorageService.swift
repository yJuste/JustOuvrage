//
//  ImageStorageService.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/23/26.
//

import UIKit

/// A Protocol that contains save, load and delete functions for handling Image Storage.
protocol ImageStorageService {
	
	func save(image: UIImage) throws -> String
	func load(image: String) throws -> UIImage
	func delete(image: String) throws
}
