//
//  Draft.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/2/26.
//

import SwiftUI
import SwiftData

/// A Model for a ``Draft``.
/// External Dependencies: Language, Deck
@Model final class Draft {
	
	var id: UUID
	var entry: String
	var language: Language
	var lastViewedAt: Date?
	
	init(entry: String, language: Language) {
		self.id = UUID()
		self.entry = entry
		self.language = language
		self.lastViewedAt = .now
	}
}
