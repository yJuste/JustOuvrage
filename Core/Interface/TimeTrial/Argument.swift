//
//  Argument.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/22/26.
//

import Foundation

struct Argument: Identifiable {
	
	let id: UUID
	let cards: [Card]
	let timeInterval: TimeInterval
	let deck: Deck?
	let mode: Mode
	
	init(cards: [Card], timeInterval: TimeInterval, deck: Deck?, mode: Mode = .custom) {
		self.id = UUID()
		self.cards = cards
		self.timeInterval = timeInterval
		self.deck = nil
		self.mode = mode
	}
}
