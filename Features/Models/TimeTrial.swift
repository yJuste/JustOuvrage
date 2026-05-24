//
//  TimeTrial.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/19/26.
//

import SwiftData
import Foundation

/// A Model for a  ``Session``.
/// External Dependencies: Deck, Mode
@Model final class TimeTrial {
	
	@Attribute(.unique) var id: UUID
	var cards: [TrialCard]
	var timeInterval: TimeInterval
	var deck: Deck?
	var mode: Mode
	var success: Double
	var directions: [SwipeDirection]
	
	private(set) var createdAt: Date
	
	init(argument: Argument, with success: Double) {
		self.id = UUID()
		self.cards = argument.cards.map { TrialCard(frontEntry: $0.frontEntry, backEntry: $0.backEntry, frontLanguage: $0.frontLanguage, backLanguage: $0.backLanguage) }
		self.timeInterval = argument.timeInterval
		self.deck = argument.deck
		self.mode = argument.mode
		self.success = success
		self.directions = argument.directions
		self.createdAt = .now
	}
}

struct TrialCard: Codable {
	
	let frontEntry: String
	let backEntry: String
	let frontLanguage: Language
	let backLanguage: Language
}
