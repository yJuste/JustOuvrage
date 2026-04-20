//
//  Card.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftData
import Foundation

/// A Model for a Card.
/// External Dependencies: Language
@Model final class Card {
	
	var frontEntry: String
	var backEntry: String
	var frontLanguage: Language
	var backLanguage: Language
	
	var deck: Deck?
	
	private(set) var leitnerScore: Int
	private(set) var createdAt: Date
	
	init(frontEntry: String, backEntry: String, frontLanguage: Language, backLanguage: Language) {
		self.frontEntry = frontEntry
		self.backEntry = backEntry
		self.frontLanguage = frontLanguage
		self.backLanguage = backLanguage
		self.deck = nil
		self.leitnerScore = 1
		self.createdAt = .now
	}
}
