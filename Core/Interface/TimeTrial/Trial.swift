//
//  Trial.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/22/26.
//

import Foundation

struct Trial {
	
	static func make(cards: [Card], deck: Deck?, mode: Mode, order: SortTrial, numberOfCards: Int, interval: TimeInterval) -> Argument {
		
		var res = cards
		
		if let deck {
			res = res.filter { $0.decks.contains(deck) }
		}
		
		var finalInterval = interval
		
		switch mode {
		case .chill:
			res = res.sorted { $0.createdAt > $1.createdAt }
			finalInterval = 31_536_000
		case .standard:
			res.shuffle()
			finalInterval = 4.0
		case .death:
			res.shuffle()
			finalInterval = 1.5
		case .custom:
			switch order {
			case .random: res.shuffle()
			case .newestToOldest: res = res.sorted { $0.createdAt > $1.createdAt }
			case .oldestToNewest: res = res.sorted { $0.createdAt < $1.createdAt }
			case .alphabeticalAscending:
				res = res.sorted {
					if $0.frontEntry == $1.frontEntry {
						return $0.backEntry.localizedCaseInsensitiveCompare($1.backEntry) == .orderedAscending
					}
					return $0.frontEntry.localizedCaseInsensitiveCompare($1.frontEntry) == .orderedAscending
				}
			case .alphabeticalDescending:
				res = res.sorted {
					if $0.frontEntry == $1.frontEntry {
						return $0.backEntry.localizedCaseInsensitiveCompare($1.backEntry) == .orderedDescending
					}
					return $0.frontEntry.localizedCaseInsensitiveCompare($1.frontEntry) == .orderedDescending
				}
			}
		}
		
		if numberOfCards > 0 {
			res = Array(res.prefix(numberOfCards))
		}
		
		return Argument(cards: res, timeInterval: finalInterval, deck: deck, mode: mode)
	}
}
