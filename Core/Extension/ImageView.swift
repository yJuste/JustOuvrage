//
//  ImageView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/25/26.
//

import SwiftUI

extension Image {
	
	/// Displays an image from ``ImageStorageService``.
	///
	/// - Parameters:
	///   - image: The name of the image file to load.
	///   - storage: The storage system used to retrieve the image.
	///
	/// - Returns: A `SwiftUI.Image` created from the stored file, or a default image if loading fails.
	///
	/// - Note: Requires `FileImageStorage` and `Constants` dependencies.
	///
	/// ## Example
	/// ```swift
	/// Image(image: "path/card_01.png", storage: fileImageStorage)
	/// ```
	init(image: String, storage: ImageStorageService) {
		if let uiImage = try? storage.load(image: image) {
			self = Image(uiImage: uiImage)
		} else {
			self = Image(Constants.defaultDeckImage)
		}
	}
}
