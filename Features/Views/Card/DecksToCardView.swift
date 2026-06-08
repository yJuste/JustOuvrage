//
//  DecksToCardView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

import SwiftUI
import SwiftData

/// A view that adds Decks to a Card.
struct DecksToCardView: View {
	
	let card: Card
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@State private var search: String = ""
	@State private var selectedDecks: Set<Deck.ID> = []
	@State private var sorts: [SortDeck] = [.newestToOldest]
	
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
			.toolbar { toolbar }
			.tint(nil)
			.listStyle(.plain)
			.searchable(text: $search)
		}
	}
}

fileprivate extension DecksToCardView {
	
	private func toggleSort(first: SortDeck, second: SortDeck) {
		if sorts.contains(first) {
			sorts.removeAll { $0 == first }
			if !sorts.contains(second) {
				sorts.insert(second, at: 0)
			}
		} else {
			sorts.removeAll { $0 == second }
			if !sorts.contains(first) {
				sorts.insert(first, at: 0)
			}
		}
	}
}

/// Toolbar.
fileprivate extension DecksToCardView {
	
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
				Text("Add To Decks")
					.font(.headline)
				Text("for \"\(card.frontEntry)\"")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				Section {
					Button {
						toggleSort(first: .newestToOldest, second: .oldestToNewest)
					} label: {
						let contain = sorts.contains(.newestToOldest)
						Label("Date", systemImage: contain ? "text.line.first.and.arrowtriangle.forward" : "text.line.last.and.arrowtriangle.forward")
						Text(contain ? "Newest to Oldest" : "Oldest to Newest")
					}
					
					Button {
						toggleSort(first: .alphabeticalAscending, second: .alphabeticalDescending)
					} label: {
						let contain = sorts.contains(.alphabeticalAscending)
						Label("Name", systemImage: contain ? "text.line.first.and.arrowtriangle.forward" : "text.line.last.and.arrowtriangle.forward")
						Text(contain ? "Ascending" : "Descending")
					}
				}
			} label: {
				Label("Filter", systemImage: "line.3.horizontal.decrease")
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

#Preview {
	DecksToCardView(card: Card(frontEntry: "Hello", backEntry: "No", frontLanguage: .fr_CA, backLanguage: .en_US, author: "yJuste"))
}
