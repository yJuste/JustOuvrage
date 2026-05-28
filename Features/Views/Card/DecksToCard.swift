//
//  DecksToCard.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/11/26.
//

import SwiftUI
import SwiftData

/// A view that adds Decks to a Card.
struct DecksToCard: View {
	
	let card: Card
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@State private var search: String = ""
	@State private var selectedDecks: Set<Deck.ID> = []
	
	private var filteredDecks: [Deck] {
		guard !search.isEmpty else { return decks }
		return decks.filter {
			$0.name.localizedCaseInsensitiveContains(search)
			|| $0.depiction.localizedCaseInsensitiveContains(search)
		}
	}
	
	var body: some View {
		NavigationStack {
			List(filteredDecks) { deck in
				let id = deck.id
				Button {
					if selectedDecks.contains(id) {
						selectedDecks.remove(id)
					} else {
						selectedDecks.insert(id)
					}
				} label: {
					HStack {
						VStack(alignment: .leading) {
							Text(deck.name)
							Text(deck.depiction)
								.foregroundStyle(.secondary)
						}
						Spacer()
						if selectedDecks.contains(id) {
							Image(systemName: "checkmark")
						}
					}
				}
			}
			.task {
				selectedDecks = Set(card.decks.map(\.id))
			}
			.listStyle(.plain)
			.toolbar { toolbar }
			.searchable(text: $search)
		}
	}
}

/// Toolbar.
fileprivate extension DecksToCard {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				dismiss()
			} label: {
				Text("Cancel")
			}
			.tint(nil)
		}
		ToolbarItem(placement: .principal) {
			VStack {
				Text("Add Decks")
					.font(.headline)
				Text("for \"\(card.frontEntry)\"")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				card.decks = decks.filter { selectedDecks.contains($0.id) }
				dismiss()
			} label: {
				Label("Done", systemImage: "checkmark")
			}
			.buttonStyle(.borderedProminent)
		}
	}
}
