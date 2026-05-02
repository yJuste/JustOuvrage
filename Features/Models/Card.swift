//
//  Card.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftData
import Foundation

/// A Model for a ``Card``.
/// External Dependencies: Language, Deck
@Model final class Card {
	
	var id: UUID
	var frontEntry: String
	var backEntry: String
	var frontLanguage: Language
	var backLanguage: Language
	var leitnerScore: Int
	var author: String
	var lastViewedAt: Date?
	
	@Relationship var decks: [Deck]
	
	private(set) var createdAt: Date
	
	init(frontEntry: String, backEntry: String, frontLanguage: Language, backLanguage: Language) {
		self.id = UUID()
		self.frontEntry = frontEntry
		self.backEntry = backEntry
		self.frontLanguage = frontLanguage
		self.backLanguage = backLanguage
		self.leitnerScore = 1
		self.author = "[author]"
		self.decks = []
		self.createdAt = .now
	}
}
