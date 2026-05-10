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
	
	let hasSearch: Bool
	let onOpenCard: (Card) -> Void
	let onOpenDeck: (Deck) -> Void
	let onOpenDraft: (Draft) -> Void
	
	@Environment(\.isSearching) private var isSearching
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.modelContext) private var context
	@Namespace private var namespace
	
	@Query(filter: #Predicate<Card> { $0.lastViewedAt != nil }, sort: \Card.lastViewedAt, order: .reverse) private var recentCards: [Card]
	@Query(filter: #Predicate<Deck> { $0.lastViewedAt != nil }, sort: \Deck.lastViewedAt, order: .reverse) private var recentDecks: [Deck]
	@Query private var recentDrafts: [Draft]
	
	@State private var showClearAllAlert: Bool = false
	
	private var recentItems: [Search] {
		
		let cards = recentCards.map { Search.card($0, back: false) }
		let decks = recentDecks.map(Search.deck)
		let drafts = recentDrafts.map(Search.draft)
		
		return (cards + decks + drafts)
			.sorted { $0.date > $1.date }
	}
	
	var body: some View {
		if isSearching && !hasSearch {
			Section {
				ForEach(recentItems.prefix(Constants.maxRecentSearches)) { item in
					switch item {
					case .card(let card, _):
						Section {
							Button {
								onOpenCard(card)
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
						} /// ``Preview for a Card``
					case .deck(let deck):
						Section {
							Button {
								onOpenDeck(deck)
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
						} /// ``Preview for a Deck``
					case .draft(let draft):
						Section {
							Button {
								onOpenDraft(draft)
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
						} /// ``Preview for a Draft``
					case .match( _ ):
						Section {
							Button {
								// Nothing to do
							} label: {
								// Nothing
							}
						} /// ``Preview for a Match``
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

/// Methods of SearchFocusView.
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
			case .match:
				break
			}
		}
	}
}

//#Preview {
//	
//	NavigationStack {
//		SearchFocusView(hasSearch: false)
//			.searchable(text: .constant(""))
//			.environment(FileImageStorage())
//	}
//}
