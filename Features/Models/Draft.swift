//
//  Draft.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/2/26.
//

import SwiftData
import Foundation

/// A Model for a ``Draft``.
/// External Dependencies: Language, Deck
@Model final class Draft {
	
	@Attribute(.unique) var id: UUID
	var entry: String
	var language: Language
	var lastViewedAt: Date?
	
	private(set) var createdAt: Date
	
	init(entry: String, language: Language) {
		self.id = UUID()
		self.entry = entry
		self.language = language
		self.lastViewedAt = .now
		self.createdAt = .now
	}
}
