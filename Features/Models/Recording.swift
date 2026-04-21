//
//  Recording.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

import SwiftData
import Foundation

// MARK: The recording files could be stored with an another way than SwiftData.

/// A built-in recorder.
@Model final class Recording: Identifiable, Equatable {
	
	var id = UUID()
	var url: URL
	var date: Date
	var sequence: Int
	
	init(id: UUID = UUID(), url: URL, date: Date, sequence: Int) {
		self.id = id
		self.url = url
		self.date = date
		self.sequence = sequence
	}
}
