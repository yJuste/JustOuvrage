//
//  Search.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/2/26.
//

import SwiftUI

/// Search interface to display recent items.
/// External Dependencies: Card, Deck, Draft
enum Search: Identifiable {
	
	case card(Card, back: Bool)
	case deck(Deck)
	case draft(Draft)
	case match(Draft)
	
	var id: String {
		switch self {
		case .card(let card, _): return card.id.uuidString
		case .deck(let deck): return deck.id.uuidString
		case .draft(let draft): return draft.id.uuidString
		case .match(let match): return match.id.uuidString
		}
	}
	
	var date: Date {
		switch self {
		case .card(let card, _):
			return card.lastViewedAt ?? .distantPast
		case .deck(let deck):
			return deck.lastViewedAt ?? .distantPast
		case .draft(let draft):
			return draft.lastViewedAt ?? .distantPast
		case .match(let match):
			return match.lastViewedAt ?? .distantPast
		}
	}
}
