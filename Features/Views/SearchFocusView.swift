//
//  SearchFocusView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/20/26.
//

import SwiftUI
import SwiftData
import os /// `debug`

/// A view that shows the focus state of the SearchView.
/// External Dependencies: Card, Deck, Draft, Constants, FileImageStorage, Search, CardView, DeckView, DraftView
struct SearchFocusView: View {
	
	@Binding var search: String
	
	@Environment(\.isSearching) private var isSearching
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.modelContext) private var context
	@Namespace private var namespace
	
	@Query(filter: #Predicate<Card> { $0.lastViewedAt != nil }, sort: \Card.lastViewedAt, order: .reverse) private var recentCards: [Card]
	@Query(filter: #Predicate<Deck> { $0.lastViewedAt != nil }, sort: \Deck.lastViewedAt, order: .reverse) private var recentDecks: [Deck]
	@Query private var recentDrafts: [Draft]
	
	@State private var selectedCard: Card?
	@State private var showCard: Bool = false
	@State private var selectedDeck: Deck?
	@State private var showDeck: Bool = false
	@State private var selectedDraft: Draft?
	@State private var showDraft: Bool = false
	@State private var showClearAllAlert: Bool = false
	
	private var recentItems: [Search] {
		
		let cards = recentCards.map { Search.card($0, back: false) }
		let decks = recentDecks.map(Search.deck)
		let drafts = recentDrafts.map(Search.draft)
		
		return (cards + decks + drafts)
			.sorted { $0.date > $1.date }
	}
	
	var body: some View {
		if isSearching && search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			Section {
				ForEach(recentItems.prefix(Constants.maxRecentSearches)) { item in
					switch item {
					case .card(let card, _):
						Button {
							selectedCard = card
							card.lastViewedAt = .now
							showDeck = false
							showDraft = false
							showCard = true
							trimRecentsGlobal()
						} label: {
							VStack(alignment: .leading, spacing: 5) {
								Text(card.frontEntry)
									.font(.subheadline)
								Text(card.backEntry)
									.font(.subheadline)
									.foregroundStyle(.secondary)
							}
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
							selectedDeck = deck
							deck.lastViewedAt = .now
							showCard = false
							showDraft = false
							showDeck = true
							trimRecentsGlobal()
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
					case .draft(let draft):
						Button {
							selectedDraft = draft
							draft.lastViewedAt = .now
							showCard = false
							showDeck = false
							showDraft = true
							trimRecentsGlobal()
						} label: {
							Text("\(draft.entry)")
								.font(.system(size: 15, weight: .regular, design: .default))
						}
						.swipeActions {
							Button {
								context.delete(draft)
							} label: {
								Label("Clear", systemImage: "xmark.circle.fill")
							}
						}
					case .exactMatch( _ ): Button { } label: { }
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
						.presentationDetents([
							.fraction(Constants.heightOfACard[0]),
							.fraction(Constants.heightOfACard[1])
						])
						.presentationBackgroundInteraction(.enabled)
				}
			}
			.sheet(isPresented: $showDeck) {
				if let deck = selectedDeck {
					DeckView(deck: deck, namespace: namespace)
						.presentationDetents([.fraction(Constants.heightOfADeck[0]), .large])
						.presentationBackgroundInteraction(.enabled)
						.presentationDragIndicator(.visible)
				}
			}
			.sheet(isPresented: $showDraft) {
				if let draft = selectedDraft {
					DraftView(draft: draft)
						.presentationDetents([
							.fraction(Constants.heightOfADraft[0]),
							.fraction(Constants.heightOfADraft[1])
						])
						.presentationBackgroundInteraction(.enabled)
				}
			}
			.alert("Clear Searches?", isPresented: $showClearAllAlert) {
				Button("Clear All", role: .destructive) {
					recentCards.forEach { $0.lastViewedAt = nil }
					recentDecks.forEach { $0.lastViewedAt = nil }
					recentDrafts.forEach { context.delete($0) }
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Clearing your searches will remove your search history from this device.")
			}
		}
	}
}

fileprivate extension SearchFocusView {
	
	func trimRecentsGlobal() {
		let all = recentItems
		guard all.count > Constants.maxRecentSearches else { return }
		let toRemove = all.dropFirst(Constants.maxRecentSearches)
		
		for item in toRemove {
			switch item {
			case .card(let card, _):
				card.lastViewedAt = nil
			case .deck(let deck):
				deck.lastViewedAt = nil
			case .draft(let draft):
				context.delete(draft)
			case .exactMatch:
				break
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
