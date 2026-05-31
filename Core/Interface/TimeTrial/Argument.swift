//
//  Argument.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/22/26.
//

import Foundation

struct Argument: Identifiable {
	
	let id: UUID
	let deck: Deck?
	let cards: [Card]
	let side: Side
	let reversedCards: [UUID: Bool]
	let mode: Mode
	let timeInterval: TimeInterval
	let order: SortTrial
	var directions: [SwipeDirection]
	
	fileprivate init(deck: Deck?, cards: [Card], side: Side, reversedCards: [UUID: Bool], mode: Mode = .custom, directions: [SwipeDirection], timeInterval: TimeInterval, order: SortTrial) {
		self.id = UUID()
		self.deck = deck
		self.cards = cards
		self.side = side
		self.reversedCards = reversedCards
		self.mode = mode
		self.timeInterval = timeInterval
		self.order = order
		self.directions = directions
	}
	
	init(cards: [Card]) {
		self.id = UUID()
		self.deck = nil
		self.cards = cards
		self.side = .front
		self.reversedCards = [:]
		self.mode = .chill
		self.timeInterval = Constants.infinityYear
		self.order = .random
		self.directions = []
	}
}

extension Argument {
	
	static func make(deck: Deck?, cards: [Card], side: Side, mode: Mode, directions: [SwipeDirection], timeInterval: TimeInterval, order: SortTrial, numberOfCards: Int) -> Argument {
		
		var res = cards
		var newInterval = timeInterval
		var newOrder = order
		var newSide = side
		
		if let deck { res = res.filter { $0.decks.contains(deck) } }
		
		switch mode {
		case .chill: res = res.sorted { $0.createdAt > $1.createdAt }; newInterval = Constants.infinityYear; newOrder = .newestToOldest
		case .standard: res.shuffle(); newInterval = 5.0; newOrder = .random; newSide = .both
		case .death: res.shuffle(); newInterval = 1.5; newOrder = .random; newSide = .both
		case .custom:
			switch order {
			case .random: res.shuffle()
			case .newestToOldest: res = res.sorted { $0.createdAt > $1.createdAt }
			case .oldestToNewest: res = res.sorted { $0.createdAt < $1.createdAt }
			case .alphabeticalAscending: res = res.sorted { if $0.frontEntry == $1.frontEntry { return $0.backEntry.localizedStandardCompare($1.backEntry) == .orderedAscending }; return $0.frontEntry.localizedStandardCompare($1.frontEntry) == .orderedAscending }
			case .alphabeticalDescending: res = res.sorted { if $0.frontEntry == $1.frontEntry { return $0.backEntry.localizedStandardCompare($1.backEntry) == .orderedDescending }; return $0.frontEntry.localizedStandardCompare($1.frontEntry) == .orderedDescending }
			}
		}
		
		if numberOfCards > 0 { res = Array(res.prefix(numberOfCards)) }
		
		let reversedCards: [UUID: Bool] = Dictionary(uniqueKeysWithValues: res.map { card in
			
			let reversed: Bool
			switch newSide {
			case .front: reversed = false
			case .back: reversed = true
			case .both:reversed = Bool.random()
			}
			return (card.id, reversed)
		}
		)
		return Argument(deck: deck, cards: res, side: newSide, reversedCards: reversedCards, mode: mode, directions: directions, timeInterval: newInterval, order: newOrder)
	}
}
