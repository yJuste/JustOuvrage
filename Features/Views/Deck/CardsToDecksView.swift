//
//  CardsToDecksView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/10/26.
//

import SwiftUI
import SwiftData

struct CardsToDecksView: View {
	
	let decks: Set<Deck>
	
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
			filtered = base.filter { card in
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
				let isSelected = selectedCards.contains(id)
				Button {
					if isSelected {
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
						if isSelected {
							Image(systemName: "checkmark")
						}
					}
				}
			}
			.task {
				selectedCards = Set(cards.filter { card in Set(decks.map(\.id)).isSubset(of: Set(card.decks.map(\.id))) }.map(\.id))
			}
			.toolbar { toolbar }
			.tint(nil)
			.listStyle(.plain)
			.searchable(text: $search)
		}
	}
}

fileprivate extension CardsToDecksView {
	
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

fileprivate extension CardsToDecksView {
	
	@ToolbarContentBuilder var toolbar: some ToolbarContent {
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
				Text("for \"\(decks.first?.name ?? "")\"")
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
				for deck in decks {
					deck.cards = cards.filter { selectedCards.contains($0.id) }
				}
				dismiss()
			} label: {
				Label("Done", systemImage: "checkmark")
			}
			.buttonStyle(.borderedProminent)
		}
	}
}
