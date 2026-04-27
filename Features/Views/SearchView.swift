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
/// External Dependencies: Card, SearchFocusView, Constants
struct SearchView: View {
	
	@Environment(FileImageStorage.self) private var storage
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@Query(filter: #Predicate<Card> { $0.lastViewedAt != nil }, sort: \Card.lastViewedAt, order: .reverse) private var recents: [Card]
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@State private var search: String = ""
	@State private var showPicker: Bool = false
	@State private var select: Filter = .all
	
	var body: some View {
		NavigationStack {
			List {
				SearchFocusView(search: $search)
				ForEach(filteredResults) { result in
					switch result {
					case .card(let card):
						Button {
							card.lastViewedAt = .now
							trimRecents()
						} label: {
							Label {
								Text(card.frontEntry)
									.font(.subheadline)
							} icon: {
								Image(systemName: "magnifyingglass")
									.font(.caption)
									.foregroundStyle(.secondary)
							}
						}
					case .deck(let deck):
						Button {
							deck.lastViewedAt = .now
						} label: {
							HStack(spacing: 12) {
								Image(image: deck.image, storage: storage)
									.resizable()
									.scaledToFill()
									.frame(width: 58, height: 58)
									.clipShape(RoundedRectangle(cornerRadius: 4))
								VStack(alignment: .leading, spacing: 2) {
									Text(deck.name)
										.font(.system(size: 15, weight: .regular, design: .default))
									Text(deck.depiction)
										.font(.system(size: 15, weight: .regular, design: .default))
										.foregroundStyle(.secondary)
								}
								Spacer()
								Button {
									//
								} label: {
									Image(systemName: "ellipsis")
										.font(.system(size: 20, weight: .bold))
								}
								.padding(.trailing, 10)
							}
						}
						.buttonStyle(.plain)
						.listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
					}
				}
			}
			.safeAreaInset(edge: .top) {
				if !search.isEmpty {
					Picker("", selection: $select) {
						Text("All")
							.tag(Filter.all)
						Text("Only Cards")
							.tag(Filter.cards)
						Text("Only Decks")
							.tag(Filter.decks)
					}
					.pickerStyle(.segmented)
					.scaleEffect(1.2)
					.padding(.horizontal, 40)
					.padding(.vertical, 10)
					.offset(y: showPicker ? 0 : -20)
					.opacity(showPicker ? 1 : 0)
					.animation(.easeInOut(duration: 0.15), value: showPicker)
				}
			}
			.onChange(of: search) { _, newValue in
				showPicker = !newValue.isEmpty
			}
			.searchable(text: $search, placement: .toolbar)
			.scrollDismissesKeyboard(.immediately)
			.navigationTitle("Search")
			.listStyle(.plain)
		}
	}
	
	private func trimRecents() {
		
		guard recents.count > Constants.maxRecents else { return }
		for card in recents.dropFirst(Constants.maxRecents) {
			card.lastViewedAt = nil
		}
	}
}

/// Filtered results between Cards/Decks.
extension SearchView {
	
	private enum SearchResult: Identifiable {
		
		case card(Card)
		case deck(Deck)
		
		var id: String {
			switch self {
			case .card(let card): return card.id
			case .deck(let deck): return deck.id
			}
		}
	}
	
	private enum Filter: Int {
		
		case all
		case cards
		case decks
	}
	
	private var filteredResults: [SearchResult] {
		
		let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return [] }
		let cardResults = cards.filter { $0.frontEntry.localizedCaseInsensitiveContains(trimmed) }.map { SearchResult.card($0) }
		let deckResults = decks.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }.map { SearchResult.deck($0) }
		switch select {
		case .all:
			return cardResults + deckResults
		case .cards:
			return cardResults
		case .decks:
			return deckResults
		}
	}
}

#Preview {
	SearchPreview()
}

struct SearchPreview: View {
	
	let container: ModelContainer = {
		let container = try! ModelContainer(for: Card.self, Deck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		let context = container.mainContext
		context.insert(Card(frontEntry: "dig in", backEntry: "mangez!", frontLanguage: .en_US, backLanguage: .fr_FR))
		context.insert(Card(frontEntry: "hello", backEntry: "bonjour", frontLanguage: .en_US, backLanguage: .fr_FR))
		return container
	}()
	
	@State private var search = ""
	
	var body: some View {
		SearchView()
			.environment(FileImageStorage())
			.modelContainer(container)
	}
}
