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
	var cards: [Card]
	var timeInterval: TimeInterval
	var deck: Deck?
	var mode: Mode
	var success: Double
	
	private(set) var createdAt: Date
	
	init(argument: Argument, with success: Double) {
		self.id = UUID()
		self.cards = argument.cards
		self.timeInterval = argument.timeInterval
		self.deck = argument.deck
		self.mode = argument.mode
		self.success = success
		self.createdAt = .now
	}
}
