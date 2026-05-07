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
	@Environment(\.modelContext) private var context
	@Namespace private var namespace
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	@Query private var drafts: [Draft]
	
	@State private var search: String = ""
	@State private var showPicker: Bool = false
	@State private var select: Int = 0
	@State private var selectedCard: Card?
	@State private var showCard: Bool = false
	@State private var selectedDeck: Deck?
	@State private var showDeck: Bool = false
	@State private var selectedMatch: Draft?
	@State private var showExactMatch: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				SearchFocusView(search: $search)
				ForEach(filteredResults) { result in
					switch result {
					case .card(let card, let back):
						Button {
							selectedCard = card
							card.lastViewedAt = .now
							showDeck = false
							showExactMatch = false
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
					case .deck(let deck):
						Button {
							selectedDeck = deck
							deck.lastViewedAt = .now
							deck.lastOpenedAt = .now
							showCard = false
							showExactMatch = false
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
					case .draft( _ ): Button { } label: { }
					case .exactMatch(let match):
						Button {
							if let existingDraft = drafts.first(where: { $0.entry == match }) {
								selectedMatch = existingDraft
							} else {
								let draft = Draft(entry: match, language: .en_US)
								context.insert(draft)
								selectedMatch = draft
							}
							showCard = false
							showDeck = false
							showExactMatch = true
						} label: {
							Label {
								Text("\"\(match)\"")
							} icon: {
								Image(systemName: "magnifyingglass.circle.fill")
							}
							.font(.headline)
							.fontWeight(.medium)
							.foregroundStyle(.accent)
						}
					}
				}
			}
			.searchable(text: $search, placement: .toolbar)
			.onChange(of: search) { _, newValue in
				showPicker = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			}
			.safeAreaInset(edge: .top) {
				if !search.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
					Picker("", selection: $select) {
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
					.offset(y: showPicker ? 0 : -20)
					.opacity(showPicker ? 1 : 0)
					.animation(.easeInOut(duration: 0.15), value: showPicker)
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
			.sheet(isPresented: $showExactMatch) {
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
		}
	}
}

/// Filtered results between Cards/Decks.
fileprivate extension SearchView {
	
	private var filteredResults: [Search] {
		let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return [] }
		
		let exactResult: [Search] = [.exactMatch(trimmed)]
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
		
		switch select {
		case 0:
			return exactResult + cardResults + deckResults
		case 1:
			return cardResults
		case 2:
			return deckResults
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
