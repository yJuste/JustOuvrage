//
//  CardsToDeck.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/28/26.
//

import SwiftUI
import SwiftData

/// A view that adds Cards to a Deck.
/// External Dependencies: Card, Deck
struct CardsToDeck: View {
	
	let deck: Deck
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@State private var search: String = ""
	@State private var selectedCards: Set<Card.ID> = []
	@State private var selectedLanguages: Set<String> = []
	@State private var languageFilter: LanguageFilter = .atLeastOne
	
	private var filteredCards: [Card] {
		let base: [Card]
		
		if search.isEmpty {
			base = cards
		} else {
			base = cards.filter { $0.frontEntry.localizedCaseInsensitiveContains(search) || $0.backEntry.localizedCaseInsensitiveContains(search)
			}
		}
		let filtered: [Card]
		
		if selectedLanguages.isEmpty {
			filtered = base
		} else {
			switch languageFilter {
			case .atLeastOne: filtered = base.filter {
				selectedLanguages.contains($0.frontLanguage.code) || selectedLanguages.contains($0.backLanguage.code)
			}
			case .justOne: filtered = base.filter {
				let front = $0.frontLanguage.code
				let back = $0.backLanguage.code
				guard front != back else { return false }
				
				if selectedLanguages.count == 1 {
					return selectedLanguages.contains(front) || selectedLanguages.contains(back)
				}
				return selectedLanguages.contains(front) && selectedLanguages.contains(back)
			}
			case .needBoth: filtered = base.filter {
				let front = $0.frontLanguage.code
				return front == $0.backLanguage.code && selectedLanguages.contains(front)
			}
			}
		}
		return filtered
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

/// Toolbar.
fileprivate extension CardsToDeck {
	
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
						switch languageFilter {
						case .atLeastOne: languageFilter = .justOne
						case .justOne: languageFilter = .needBoth
						case .needBoth: languageFilter = .atLeastOne
						}
					} label: {
						Label(languageFilter.title, systemImage: languageFilter.icon)
					}
				}
				
				Section {
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
								Image(systemName: contain ? "checkmark" : "")
							}
						}
					}
				}
			} label: {
				Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
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
	CardsToDeck(deck: Deck(name: "LOL Taylor", image: "deck"))
}
