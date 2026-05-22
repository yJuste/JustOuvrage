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
	
	init(cards: [Card], timeInterval: TimeInterval) {
		self.id = UUID()
		self.cards = cards
		self.timeInterval = timeInterval
	}
}
