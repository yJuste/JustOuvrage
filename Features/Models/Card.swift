//
//  Card.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftData
import Foundation

/// A Model for a ``Card``.
/// External Dependencies: Language
@Model final class Card: Identifiable {
	
	var id: String
	var frontEntry: String
	var backEntry: String
	var frontLanguage: Language
	var backLanguage: Language
	var leitnerScore: Int
	var lastViewedAt: Date?
	
	@Relationship var decks: [Deck]
	
	private(set) var createdAt: Date
	
	init(frontEntry: String, backEntry: String, frontLanguage: Language, backLanguage: Language) {
		self.id = UUID().uuidString
		self.frontEntry = frontEntry
		self.backEntry = backEntry
		self.frontLanguage = frontLanguage
		self.backLanguage = backLanguage
		self.lastViewedAt = nil
		self.decks = []
		self.leitnerScore = 1
		self.createdAt = .now
	}
}
