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
	
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.isSearching) private var isSearching
	@Environment(\.modelContext) private var modelContext
	@Namespace private var namespace
	
	@Query(filter: #Predicate<Card> { $0.lastViewedAt != nil }, sort: \Card.lastViewedAt, order: .reverse) private var cards: [Card]
	@Query(filter: #Predicate<Deck> { $0.lastViewedAt != nil }, sort: \Deck.lastViewedAt, order: .reverse) private var decks: [Deck]
	@Query(sort: \Draft.createdAt, order: .reverse) private var drafts: [Draft]
	
	@State private var showClearAll: Bool = false
	
	private var recentItems: [Search] {
		
		let cards = cards.map { Search.card($0, back: false) }
		let decks = decks.map(Search.deck)
		let drafts = drafts.map(Search.draft)
		
		return (cards + decks + drafts).sorted { $0.date > $1.date }
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
									Text(card.backEntry)
										.foregroundStyle(.secondary)
								}
								.font(.subheadline)
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
										Text(deck.depiction)
											.foregroundStyle(.secondary)
									}
									.font(.system(size: 15))
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
								Text(draft.entry)
									.font(.system(size: 15))
							}
							.swipeActions {
								Button {
									modelContext.delete(draft)
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
						showClearAll.toggle()
					} label: {
						Text("Clear All")
					}
					.disabled(recentItems.isEmpty)
				}
			}
			.alert("Clear Searches?", isPresented: $showClearAll) {
				Button("Clear All", role: .destructive) {
					cards.forEach { $0.lastViewedAt = nil }
					decks.forEach { $0.lastViewedAt = nil }
					drafts.forEach { modelContext.delete($0) }
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Clearing your searches will remove your search history from this device.")
			}
		} else {
			if !hasSearch {
				VStack {
					Text("How does it work?")
						.font(.headline)
					Spacer(minLength: 20)
					Text("Select the section where the words can be found: All, Only Cards, or Only Decks.")
						.font(.caption2)
						.foregroundStyle(.secondary)
					Image(.searchPickerExample)
						.resizable()
						.scaledToFit()
						.clipShape(RoundedRectangle(cornerRadius: 15))
					Spacer(minLength: 100)
					Text("Select the language you want to search in at the top of the toolbar on the left.")
						.font(.caption2)
						.foregroundStyle(.secondary)
						.clipShape(RoundedRectangle(cornerRadius: 15))
					Image(.searchDraftExample)
						.resizable()
						.scaledToFit()
				}
				.padding()
				.frame(maxWidth: .infinity)
				.background ( RoundedRectangle(cornerRadius: 15).fill(Color.accentColor.opacity(0.5)) )
				.listRowSeparator(.hidden)
			}
		}
	}
}

/// Methods of SearchFocusView.
fileprivate extension SearchFocusView {
	
	private func trimRecentsGlobal() {
		
		let all = recentItems
		let maxRecents = Constants.maxRecentSearches
		guard all.count > maxRecents else { return }
		let toRemove = all.dropFirst(maxRecents)
		
		for item in toRemove {
			switch item {
			case .card(let card, _): card.lastViewedAt = nil
			case .deck(let deck): deck.lastViewedAt = nil
			case .draft(let draft): modelContext.delete(draft)
			case .match: break
			}
		}
	}
}

#Preview {
	
	struct SearchFocusViewWrapper: View {
		
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container: ModelContainer
		
		init() {
			container = try! ModelContainer(
				for: Card.self, Deck.self, Draft.self,
				configurations: config
			)
			
			let context = container.mainContext
			
			let card = Card(
				frontEntry: "Hello",
				backEntry: "World",
				frontLanguage: .en_US,
				backLanguage: .en_US
			)
			card.lastViewedAt = .now
			
			let deck = Deck(name: "Lol", image: "deck")
			deck.lastViewedAt = .now
			
			let draft = Draft(entry: "Draft test", language: .en_US)
			
			context.insert(card)
			context.insert(deck)
			context.insert(draft)
		}
		
		var body: some View {
			NavigationStack {
				SearchFocusView(
					hasSearch: false,
					onOpenCard: { _ in },
					onOpenDeck: { _ in },
					onOpenDraft: { _ in }
				)
				.environment(\.modelContext, container.mainContext)
				.environment(FileImageStorage())
				.searchable(text: .constant(""))
			}
			.modelContainer(container)
		}
	}
	return SearchFocusViewWrapper()
}
