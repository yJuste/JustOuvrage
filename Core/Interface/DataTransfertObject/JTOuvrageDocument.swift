//
//  JTOuvrageDocument.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/30/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct JTouvrageDocument: FileDocument {
	
	static var readableContentTypes: [UTType] { [.jtouvrage] }
	
	let packageURL: URL
	
	init(packageURL: URL) { self.packageURL = packageURL }
	init(configuration: ReadConfiguration) throws { throw Errors.DataTransfer }
	
	func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { try FileWrapper(url: packageURL) }
}
