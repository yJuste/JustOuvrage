//
//  SearchView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/20/26.
//

import SwiftUI
import SwiftData
import os // MARK: debug

/// A view that shows the search scene.
/// External Dependencies: Card, SearchFocusView, DisplayConfig
struct SearchView: View {
	
	@State private var search: String = ""
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@Query(filter: #Predicate<Card> { $0.lastViewedAt != nil }, sort: \Card.lastViewedAt, order: .reverse) private var recents: [Card]
	
	private var filteredCards: [Card] {
		if search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			return []
		} else {
			return cards.filter {
				$0.frontEntry.localizedCaseInsensitiveContains(search)
			}
		}
	}
	
	var body: some View {
		NavigationStack {
			List {
				SearchFocusView(search: $search)
				ForEach(filteredCards) { card in
					VStack(alignment: .leading) {
						Button {
							card.lastViewedAt = .now
							trimRecents()
							Debug.print(level: .info, card: card)
						} label: {
							Label {
								VStack(alignment: .leading, spacing: 5) {
									Text(card.frontEntry)
										.font(.subheadline)
								}
							} icon: {
								Image(systemName: "magnifyingglass")
									.font(.caption)
									.foregroundStyle(.secondary)
							}
						}
					}
					.listRowInsets(EdgeInsets(top: 11, leading: 15, bottom: 11, trailing: 15))
				}
			}
			.navigationTitle("Search")
			.listStyle(.plain)
			.searchable(text: $search, placement: .toolbar)
			.scrollDismissesKeyboard(.immediately)
		}
	}
	
	private func trimRecents() {
		
		guard recents.count > DisplayConfig.maxRecents else { return }
		for card in recents.dropFirst(DisplayConfig.maxRecents) {
			card.lastViewedAt = nil
		}
	}
}

#Preview {
	SearchPreview()
}

struct SearchPreview: View {
	let container: ModelContainer = {
		let container = try! ModelContainer(
			for: Card.self,
			configurations: ModelConfiguration(isStoredInMemoryOnly: true)
		)

		let context = container.mainContext

		context.insert(Card(frontEntry: "dig in", backEntry: "mangez!", frontLanguage: .en_US, backLanguage: .fr_FR))
		context.insert(Card(frontEntry: "hello", backEntry: "bonjour", frontLanguage: .en_US, backLanguage: .fr_FR))

		return container
	}()

	@State private var search = ""

	var body: some View {
		SearchView()
			.modelContainer(container)
	}
}
