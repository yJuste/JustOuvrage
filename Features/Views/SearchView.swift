//
//  SearchView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/20/26.
//

import SwiftUI
import SwiftData
import os /// `debug`

/// A view that shows the search scene.
/// External Dependencies: Card, Deck, Draft, Language, Search, SearchFocusView, Constants, FileImageStorage
struct SearchView: View {
	
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.modelContext) private var modelContext
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	@Query private var drafts: [Draft]
	
	@State private var search: String = ""
	@State private var selectPicker: Int = 0
	@State private var selectedCard: Card?
	@State private var showCard: Bool = false
	@State private var selectedDeck: Deck?
	@State private var showDeck: Bool = false
	@State private var selectedDraft: Draft?
	@State private var showDraft: Bool = false
	@State private var selectedMatch: Draft?
	@State private var showMatch: Bool = false
	
	private var hasSearch: Bool {
		!search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}
	
	var body: some View {
		NavigationStack {
			List {
				SearchFocusView(
					hasSearch: hasSearch,
					onOpenCard: { card in
						selectedCard = card
						card.lastViewedAt = .now
						showDeck = false
						showMatch = false
						showCard = true
					},
					onOpenDeck: { deck in
						selectedDeck = deck
						deck.lastViewedAt = .now
						deck.lastOpenedAt = .now
						showCard = false
						showMatch = false
						showDeck = true
					},
					onOpenDraft: { draft in
						selectedMatch = draft
						draft.lastViewedAt = .now
						showCard = false
						showDeck = false
						showMatch = true
					}
				)
				ForEach(filteredResults) { result in
					switch result {
					case .card(let card, let back):
						Section {
							Button {
								selectedCard = card
								card.lastViewedAt = .now
								showDeck = false
								showMatch = false
								showCard = true
							} label: {
								Label {
									Text("\(back ? card.backEntry : card.frontEntry)")
										.font(.subheadline)
								} icon: {
									Image(systemName: "magnifyingglass")
										.font(.caption)
										.foregroundStyle(.secondary)
								}
							}
						} /// ``Search for a Card``
					case .deck(let deck):
						Section {
							Button {
								selectedDeck = deck
								deck.lastViewedAt = .now
								deck.lastOpenedAt = .now
								showCard = false
								showMatch = false
								showDeck = true
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
						} /// ``Search for a Deck``
					case .draft( _ ):
						Section {
							Button {
								// Nothing to do
							} label: {
								// Nothing
							}
						} /// ``Search for a Draft``
					case .match(let match):
						Section {
							Button {
								let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
								if let existingDraft = drafts.first(where: { $0.entry == trimmed }) {
									selectedMatch = existingDraft
									existingDraft.lastViewedAt = .now
								} else {
									let newDraft = Draft(entry: trimmed, language: .en_US)
									modelContext.insert(newDraft)
									selectedMatch = newDraft
									newDraft.lastViewedAt = .now
								}
								showCard = false
								showDeck = false
								showMatch = true
							} label: {
								Label {
									Text("\"\(match.entry)\"")
								} icon: {
									Image(systemName: "magnifyingglass.circle.fill")
								}
								.font(.headline)
								.fontWeight(.medium)
								.foregroundStyle(.accent)
							}
						} /// ``Search for a Match``
					}
				}
			}
			.safeAreaInset(edge: .top) {
				if !showDeck && !showCard && !showMatch {
					Picker("", selection: $selectPicker) {
						Text("All")
							.tag(0)
						Text("Only Cards")
							.tag(1)
						Text("Only Decks")
							.tag(2)
					}
					.pickerStyle(.segmented)
					.scaleEffect(1.2)
					.padding(.horizontal, 40)
					.padding(.vertical, 10)
					.offset(y: hasSearch ? 0 : -20)
					.opacity(hasSearch ? 1 : 0)
					.animation(.easeInOut(duration: 0.15), value: hasSearch)
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
					DeckView(deck: deck, namespace: nil)
						.presentationDetents([
							.fraction(Constants.heightOfADeck[0]),
							.large
						])
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
			.sheet(isPresented: $showMatch) {
				if let match = selectedMatch {
					DraftView(draft: match)
						.presentationDetents([
							.fraction(Constants.heightOfADraft[0]),
							.fraction(Constants.heightOfADraft[1])
						])
						.presentationBackgroundInteraction(.enabled)
				}
			}
			.scrollDismissesKeyboard(.immediately)
			.navigationTitle("Search")
			.listStyle(.plain)
			.searchable(text: $search, placement: .toolbar)
		}
	}
}

/// Filtered results between Cards/Decks.
fileprivate extension SearchView {
	
	private var filteredResults: [Search] {
		let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return [] }
		
		let exactResult: [Search] = [.match(Draft(entry: trimmed, language: .en_US))]
		let cardResults = cards.compactMap { card -> Search? in
			let matchFront = card.frontEntry.localizedCaseInsensitiveContains(trimmed)
			let matchBack = card.backEntry.localizedCaseInsensitiveContains(trimmed)

			switch (matchFront, matchBack) {
			case (true, true):
				return .card(card, back: false)
			case (true, false):
				return .card(card, back: false)
			case (false, true):
				return .card(card, back: true)
			default:
				return nil
			}
		}
		let deckResults = decks
			.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
			.map { Search.deck($0) }
		
		switch selectPicker {
		case 0:
			return exactResult + cardResults + deckResults
		case 1:
			return exactResult + cardResults
		case 2:
			return exactResult + deckResults
		default:
			return exactResult + cardResults + deckResults
		}
	}
}

#Preview {
	
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
	return SearchPreview()
}
