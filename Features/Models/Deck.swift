//
//  Deck.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

import SwiftData
import Foundation

/// A model for a ``deck`` of cards.
/// External Dependencies: Card
@Model final class Deck {
	
	var id: UUID
	var name: String
	var depiction: String
	var author: String
	var image: String
	var lastViewedAt: Date?
	var lastOpenedAt: Date?
	
	@Relationship(inverse: \Card.decks) var cards: [Card]
	
	private(set) var createdAt: Date
	private(set) var lockDelete: Bool
	
	init(name: String, image: String) {
		self.id = UUID()
		self.name = name
		self.depiction = ""
		self.author = "[author]"
		self.image = image
		self.cards = []
		self.createdAt = .now
		self.lockDelete = false
	}
}

/// Lock a Deck from removal.
extension Deck {
	
	func lockRemoval() {
		lockDelete = true
	}
}
