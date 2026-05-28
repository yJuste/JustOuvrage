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
	let mode: Mode
	let timeInterval: TimeInterval
	let order: SortTrial
	var directions: [SwipeDirection]
	
	init(deck: Deck?, cards: [Card], mode: Mode = .custom, directions: [SwipeDirection], timeInterval: TimeInterval, order: SortTrial) {
		self.id = UUID()
		self.deck = deck
		self.cards = cards
		self.mode = mode
		self.timeInterval = timeInterval
		self.order = order
		self.directions = directions
	}
	
	init(cards: [Card]) {
		self.id = UUID()
		self.deck = nil
		self.cards = cards
		self.mode = .chill
		self.timeInterval = Constants.infinityYear
		self.order = .random
		self.directions = []
	}
}

extension Argument {
	
	static func make(deck: Deck?, cards: [Card], mode: Mode, directions: [SwipeDirection], timeInterval: TimeInterval, order: SortTrial, numberOfCards: Int) -> Argument {
		
		var res = cards
		var newInterval = timeInterval
		var newOrder = order
		
		if let deck { res = res.filter { $0.decks.contains(deck) } }
		
		switch mode {
		case .chill: res = res.sorted { $0.createdAt > $1.createdAt }; newInterval = Constants.infinityYear; newOrder = .newestToOldest
		case .standard: res.shuffle(); newInterval = 5.0; newOrder = .random
		case .death: res.shuffle(); newInterval = 1.5; newOrder = .random
		case .custom:
			switch order {
			case .random: res.shuffle()
			case .newestToOldest: res = res.sorted { $0.createdAt > $1.createdAt }
			case .oldestToNewest: res = res.sorted { $0.createdAt < $1.createdAt }
			case .alphabeticalAscending:
				res = res.sorted {
					if $0.frontEntry == $1.frontEntry {
						return $0.backEntry.localizedStandardCompare($1.backEntry) == .orderedAscending
					}
					return $0.frontEntry.localizedStandardCompare($1.frontEntry) == .orderedAscending
				}
			case .alphabeticalDescending:
				res = res.sorted {
					if $0.frontEntry == $1.frontEntry {
						return $0.backEntry.localizedStandardCompare($1.backEntry) == .orderedDescending
					}
					return $0.frontEntry.localizedStandardCompare($1.frontEntry) == .orderedDescending
				}
			}
		}
		
		if numberOfCards > 0 { res = Array(res.prefix(numberOfCards)) }
		
		return Argument(deck: deck, cards: res, mode: mode, directions: directions, timeInterval: newInterval, order: newOrder)
	}
}
