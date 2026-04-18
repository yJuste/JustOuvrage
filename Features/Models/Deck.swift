//
//  Deck.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

import SwiftData
import Foundation

/// A model for a deck of cards.
/// External Dependencies: Card
@Model
final class Deck {
	
	var name: String
	var cards: [Card]
	
	var createdAt: Date
	
	init(name: String) {
		self.name = name
		self.cards = []
		self.createdAt = .now
	}
}
