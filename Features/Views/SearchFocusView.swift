//
//  SearchFocusView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/20/26.
//

import SwiftUI
import SwiftData
import os /// `debug`

// MARK: I Have to add recent for albums too.

/// A view that shows the focus state of the SearchView.
/// External Dependencies: Card, Deck, Constants
struct SearchFocusView: View {
	
	@Binding var search: String
	
	@Environment(\.isSearching) private var isSearching
	@Environment(FileImageStorage.self) private var storage
	@Namespace private var namespace
	
	@Query(filter: #Predicate<Card> { $0.lastViewedAt != nil }, sort: \Card.lastViewedAt, order: .reverse) private var recentCards: [Card]
	@Query(filter: #Predicate<Deck> { $0.lastViewedAt != nil }, sort: \Deck.lastViewedAt, order: .reverse) private var recentDecks: [Deck]
	
	private var recentItems: [RecentItem] {
		(recentCards.map(RecentItem.card) + recentDecks.map(RecentItem.deck))
			.sorted { $0.date > $1.date }
	}
	
	@State private var selectedCard: Card?
	@State private var showCard: Bool = false
	@State private var selectedDeck: Deck?
	@State private var showDeck: Bool = false
	@State private var showClearAllAlert: Bool = false
	
	var body: some View {
		if isSearching && search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			Section {
				ForEach(recentItems.prefix(Constants.maxRecents)) { item in
					switch item {
					case .card(let card):
						Button {
							showDeck = false
							selectedCard = card
							showCard = true
							card.lastViewedAt = .now
						} label: {
							Text("\(card.frontEntry)")
								.font(.system(size: 15, weight: .regular, design: .default))
						}
						.swipeActions {
							Button {
								card.lastViewedAt = nil
							} label: {
								Label("Clear", systemImage: "xmark.circle.fill")
							}
						}
					case .deck(let deck):
						Button {
							showCard = false
							selectedDeck = deck
							showDeck = true
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
							}
						}
						.swipeActions {
							Button {
								deck.lastViewedAt = nil
							} label: {
								Label("Clear", systemImage: "xmark.circle.fill")
							}
						}
					}
				}
			} header: {
				HStack {
					Text("Recently Searched")
					Spacer()
					Button {
						showClearAllAlert.toggle()
					} label: {
						Text("Clear All")
					}
					.disabled(recentItems.isEmpty)
				}
			}
			.sheet(isPresented: $showCard) {
				if let card = selectedCard {
					CardView(card: card)
						.presentationDetents([.fraction(0.3), .fraction(0.4)])
						.presentationBackgroundInteraction(.enabled)
				}
			}
			.sheet(isPresented: $showDeck) {
				if let deck = selectedDeck {
					DeckView(deck: deck, namespace: namespace)
						.presentationDetents([.height(Constants.deck), .large])
						.presentationBackgroundInteraction(.enabled)
						.presentationDragIndicator(.hidden)
				}
			}
			.alert("Clear Searches?", isPresented: $showClearAllAlert) {
				Button("Clear All", role: .destructive) {
					recentCards.forEach { $0.lastViewedAt = nil }
					recentDecks.forEach { $0.lastViewedAt = nil }
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Clearing your searches will remove your search history from this device.")
			}
		}
	}
}

fileprivate extension SearchFocusView {
	
	private enum RecentItem: Identifiable {
		
		case card(Card)
		case deck(Deck)
		
		var id: UUID {
			switch self {
			case .card(let card): return card.id
			case .deck(let deck): return deck.id
			}
		}
		
		var date: Date {
			switch self {
			case .card(let card):
				return card.lastViewedAt ?? .distantPast
			case .deck(let deck):
				return deck.lastViewedAt ?? .distantPast
			}
		}
	}
}

#Preview {
	
	NavigationStack {
		SearchFocusView(search: .constant(""))
			.searchable(text: .constant(""))
			.environment(FileImageStorage())
	}
}
