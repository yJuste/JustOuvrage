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
	
	case card(Card)
	case deck(Deck)
	case draft(Draft)
	case exactMatch(String)
	
	var id: String {
		switch self {
		case .card(let card): return card.id.uuidString
		case .deck(let deck): return deck.id.uuidString
		case .draft(let draft): return draft.id.uuidString
		case .exactMatch(let match): return "\(match)"
		}
	}
	
	var date: Date {
		switch self {
		case .card(let card):
			return card.lastViewedAt ?? .distantPast
		case .deck(let deck):
			return deck.lastViewedAt ?? .distantPast
		case .draft(let draft):
			return draft.lastViewedAt ?? .distantPast
		case .exactMatch(_):
			return .now
		}
	}
}
