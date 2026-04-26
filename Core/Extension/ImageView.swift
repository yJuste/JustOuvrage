//
//  ImageView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/25/26.
//

import SwiftUI

/// Add an extension for the view Image.
/// Image() can now take a storage -> ``Image( String, FileImageStorage )``
/// External Dependencies: FileImageStorage, Constants
extension Image {
	
	init(image: String, storage: FileImageStorage) {
		if let uiImage = try? storage.load(image: image) {
			self = Image(uiImage: uiImage)
		} else {
			self = Image(Constants.defaultDeckImage)
		}
	}
}
