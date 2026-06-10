//
//  CardsToDeckView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

import SwiftUI
import SwiftData

/// A view that adds Cards to a Deck.
/// External Dependencies: Card, Deck
struct CardsToDeckView: View {
	
	let deck: Deck
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@State private var search: String = ""
	@State private var selectedCards: Set<Card.ID> = []
	@State private var selectedLanguages: Set<String> = []
	@State private var languageFilter: LanguageFilter = .atLeastOne
	@State private var sorts: [SortCard] = [.newestToOldest]
	
	private var filteredCards: [Card] {
		let base: [Card]
		
		if search.isEmpty {
			base = cards
		} else {
			base = cards.filter {
				$0.frontEntry.localizedCaseInsensitiveContains(search) || $0.backEntry.localizedCaseInsensitiveContains(search)
			}
		}
		let filtered: [Card]
		
		if selectedLanguages.isEmpty {
			filtered = base
		} else {
			let selected = Set(selectedLanguages)
			filtered = cards.filter { card in
				let front = card.frontLanguage.code
				let back = card.backLanguage.code
				let match = selected.contains(front) || selected.contains(back)
				let same = front == back && selected.contains(front)
				switch languageFilter {
				case .atLeastOne: return match
				case .justOne: if same { return false }; return match
				case .needBoth: return same
				}
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
			List(filteredCards) { card in
				let id = card.id
				Button {
					if selectedCards.contains(id) {
						selectedCards.remove(id)
					} else {
						selectedCards.insert(id)
					}
				} label: {
					HStack {
						VStack(alignment: .leading) {
							Text(card.frontEntry)
							Text(card.backEntry)
								.foregroundStyle(.secondary)
						}
						Spacer()
						if selectedCards.contains(id) {
							Image(systemName: "checkmark")
						}
					}
				}
			}
			.task {
				selectedCards = Set(deck.cards.map(\.id))
			}
			.toolbar { toolbar }
			.tint(nil)
			.listStyle(.plain)
			.searchable(text: $search)
		}
	}
}

/// Methods of CardsToDeckView.
fileprivate extension CardsToDeckView {
	
	private func toggleSort(first: SortCard, second: SortCard) {
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
fileprivate extension CardsToDeckView {
	
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
				Section {
					Button {
						switch languageFilter {
						case .atLeastOne: languageFilter = .justOne
						case .justOne: languageFilter = .needBoth
						case .needBoth: languageFilter = .atLeastOne
						}
					} label: {
						Label(languageFilter.title, systemImage: languageFilter.icon)
					}
					ForEach(Language.codes, id: \.self) { language in
						let contain = selectedLanguages.contains(language)
						Button {
							if contain {
								selectedLanguages.remove(language)
							} else {
								selectedLanguages.insert(language)
							}
						} label: {
							Label {
								Text(language)
							} icon: {
								Image(systemName: "checkmark")
									.hidden(!contain)
							}
						}
					}
				}
			} label: {
				Label("Filter", systemImage: "line.3.horizontal.decrease")
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

#Preview {
	CardsToDeckView(deck: Deck(name: "LOL Taylor", image: "deck", author: "yJuste"))
}
