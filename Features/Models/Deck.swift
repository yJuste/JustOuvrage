//
//  Deck.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

import SwiftData
import Foundation

/// A model for a `deck` of cards.
/// External Dependencies: Card
@Model final class Deck {
	
	@Attribute(.unique) var id: UUID
	var name: String
	var image: String
	var depiction: String
	var author: String
	var lastViewedAt: Date?
	var lastOpenedAt: Date?
	var lastDownloadAt: Date?
	
	@Relationship(inverse: \Card.decks) var cards: [Card]
	
	private(set) var createdAt: Date
	
	init(name: String, image: String) {
		self.id = UUID()
		self.name = name
		self.image = image
		self.depiction = ""
		self.author = "[author]"
		self.cards = []
		self.createdAt = .now
	}
}
