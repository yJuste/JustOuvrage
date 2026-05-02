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
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	@Query private var drafts: [Draft]
	
	@State private var search: String = ""
	@State private var showPicker: Bool = false
	@State private var select: Int = 0
	@State private var showExactMatch: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				SearchFocusView(search: $search)
				ForEach(filteredResults) { result in
					switch result {
					case .card(let card):
						Button {
							card.lastViewedAt = .now
						} label: {
							Label {
								Text("\(card.frontEntry)")
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
					case .draft( _ ): Button { } label: { }
					case .exactMatch(let match):
						Button {
							let normalized = match.trimmingCharacters(in: .whitespacesAndNewlines)
							if let existing = drafts.first(where: { $0.entry.caseInsensitiveCompare(normalized) == .orderedSame }) {
								existing.lastViewedAt = .now
							} else {
								let draft = Draft(entry: normalized, language: .en_US)
								context.insert(draft)
							}
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
			.onChange(of: search) { _, newValue in
				showPicker = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
			}
			.sheet(isPresented: $showExactMatch) {
				
			}
			.searchable(text: $search, placement: .toolbar)
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
		let cardResults = cards
			.filter { $0.frontEntry.localizedCaseInsensitiveContains(trimmed) }
			.map { Search.card($0) }
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
