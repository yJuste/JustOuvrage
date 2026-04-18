//
//  Card.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftData
import Foundation

/// A Model for a Card.
/// External Dependencies: LanguageCode
@Model
final class Card {
	
	var frontEntry: String
	var backEntry: String
	var frontLanguageCode: LanguageCode
	var backLanguageCode: LanguageCode
	
	var deck: Deck?
	
	private(set) var leitnerScore: Int
	private(set) var createdAt: Date
	
	init(frontEntry: String, backEntry: String, frontLanguageCode: LanguageCode, backLanguageCode: LanguageCode) {
		self.frontEntry = frontEntry
		self.backEntry = backEntry
		self.frontLanguageCode = frontLanguageCode
		self.backLanguageCode = backLanguageCode
		self.deck = nil
		self.leitnerScore = 1
		self.createdAt = .now
	}
}
