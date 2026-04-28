//
//  CardsToDeck.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/28/26.
//

import SwiftUI
import SwiftData

struct CardsToDeck: View {
	
	@Binding var deck: Deck
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@State private var search: String = ""
	@State private var selectedCards: Set<Card.ID> = []
	
	var filteredCards: [Card] {
		guard !search.isEmpty else { return cards }
		return cards.filter {
			$0.frontEntry.localizedCaseInsensitiveContains(search)
			|| $0.backEntry.localizedCaseInsensitiveContains(search)
		}
	}
	
	var body: some View {
		NavigationStack {
			List(filteredCards) { card in
				Button {
					if selectedCards.contains(card.id) {
						selectedCards.remove(card.id)
					} else {
						selectedCards.insert(card.id)
					}
				} label: {
					HStack {
						VStack(alignment: .leading) {
							Text(card.frontEntry)
							Text(card.backEntry)
								.foregroundStyle(.secondary)
						}
						Spacer()
						if selectedCards.contains(card.id) {
							Image(systemName: "checkmark")
						}
					}
				}
			}
			.task { selectedCards = Set(deck.cards.map(\.id)) }
			.toolbar { toolbar }
			.searchable(text: $search)
			.listStyle(.plain)
		}
	}
}

private extension CardsToDeck {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				dismiss()
			} label: {
				Text("Cancel")
			}
		}
		ToolbarItem(placement: .principal) {
			VStack {
				Text("Add Cards")
					.font(.headline)
				Text("for \"\(deck.name)\"")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				deck.cards = cards.filter { selectedCards.contains($0.id) }
				dismiss()
			} label: {
				Label("Done", systemImage: "checkmark")
			}
			.buttonStyle(.borderedProminent)
		}
	}
}
