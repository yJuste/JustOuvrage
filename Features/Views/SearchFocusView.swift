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
	
	private var recentItems: [Search] {
		(recentCards.map(Search.card) + recentDecks.map(Search.deck) + recentDrafts.map(Search.draft))
			.sorted { $0.date > $1.date }
	}
	
	@State private var selectedCard: Card?
	@State private var showCard: Bool = false
	@State private var selectedDeck: Deck?
	@State private var showDeck: Bool = false
	@State private var selectedDraft: Draft?
	@State private var showDraft: Bool = false
	@State private var showClearAllAlert: Bool = false
	
	var body: some View {
		if isSearching && search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			Section {
				ForEach(recentItems.prefix(Constants.maxRecents)) { item in
					switch item {
					case .card(let card):
						Button {
							showDeck = false
							showDraft = false
							selectedCard = card
							showCard = true
							card.lastViewedAt = .now
							trimRecentsGlobal()
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
							showDraft = false
							selectedDeck = deck
							showDeck = true
							deck.lastViewedAt = .now
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
							showCard = false
							showDeck = false
							selectedDraft = draft
							showDraft = true
							draft.lastViewedAt = .now
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
			.sheet(isPresented: $showDraft) {
				if let draft = selectedDraft {
					DraftView(draft: draft)
						.presentationDetents([.fraction(0.3), .fraction(0.4)])
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
		guard all.count > Constants.maxRecents else { return }
		let toRemove = all.dropFirst(Constants.maxRecents)
		
		for item in toRemove {
			switch item {
			case .card(let card):
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
