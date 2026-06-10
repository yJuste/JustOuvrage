//
//  DecksToCardsView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/10/26.
//

import SwiftUI
import SwiftData

struct DecksToCardsView: View {
	
	let cards: Set<Card>
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@State private var search = ""
	@State private var selectedDeckIDs: Set<Deck.ID> = []
	@State private var sorts: [SortDeck] = [.newestToOldest]
	
	private var filteredDecks: [Deck] {
		let filtered: [Deck]
		
		if search.isEmpty {
			filtered = decks
		} else {
			filtered = decks.filter {
				$0.name.localizedCaseInsensitiveContains(search) || $0.depiction.localizedCaseInsensitiveContains(search)
			}
		}
		return filtered.sorted { lhs, rhs in
			for sort in sorts {
				let result = sort.compare(lhs, rhs)
				if result != .orderedSame {
					return result == .orderedAscending
				}
			}
			return lhs.id < rhs.id
		}
	}
	
	var body: some View {
		NavigationStack {
			List(filteredDecks) { deck in
				let isSelected = selectedDeckIDs.contains(deck.id)
				Button {
					isSelected ? remove(deck) : add(deck)
				} label: {
					HStack {
						VStack(alignment: .leading) {
							Text(deck.name)
							Text(deck.depiction)
								.foregroundStyle(.secondary)
						}
						Spacer()
						if isSelected {
							Image(systemName: "checkmark")
						}
					}
				}
			}
			.toolbar { toolbar }
			.tint(nil)
			.listStyle(.plain)
			.searchable(text: $search)
			.task {
				selectedDeckIDs = cards.map { Set($0.decks.map(\.id)) }.reduce(decks.map(\.id).reduce(into: Set()) { $0.insert($1) }) { $0.intersection($1) }
			}
		}
	}
	
	private func add(_ deck: Deck) {
		selectedDeckIDs.insert(deck.id)
		for card in cards where !card.decks.contains(where: { $0.id == deck.id }) {
			card.decks.append(deck)
		}
	}
	
	private func remove(_ deck: Deck) {
		selectedDeckIDs.remove(deck.id)
		for card in cards {
			card.decks.removeAll { $0.id == deck.id }
		}
	}
}

private extension DecksToCardsView {

	func toggleSort(first: SortDeck, second: SortDeck) {
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

private extension DecksToCardsView {
	
	@ToolbarContentBuilder var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button("Cancel") {
				dismiss()
			}
		}
		ToolbarItem(placement: .principal) {
			VStack {
				Text("Add To Decks").font(.headline)
				Text("\(cards.count) cards")
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
				for card in cards {
					card.decks = decks.filter { selectedDeckIDs.contains($0.id) }
				}
				dismiss()
			} label: {
				Label("Done", systemImage: "checkmark")
			}
			.buttonStyle(.borderedProminent)
		}
	}
}
