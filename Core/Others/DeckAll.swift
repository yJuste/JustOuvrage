//
//  DeckAll.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/22/26.
//

import SwiftUI
import SwiftData

/// Create the "All" Deck when running the App for the first time.
func ensureAllDeckExists(context: ModelContext) {
	
	let decks = (try? context.fetch(FetchDescriptor<Deck>())) ?? []
	let allDecks = decks.filter { $0.lockDelete }
	
	if allDecks.isEmpty {
		let deck = Deck(name: "All", image: "deck")
		deck.lockRemoval()
		context.insert(deck)
	}
}
