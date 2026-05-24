//
//  CardsView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/26/26.
//

import SwiftUI
import SwiftData
import os /// `debug`

/// A view where all the cards are displayed.
/// External Dependencies: Card, Constants, CardView, NewCardView, NewDeckView
struct CardsView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@State private var item: Card?
	@State private var selection: Set<Card> = []
	@State private var selectedCard: Card?
	@State private var showCard: Bool = false
	@State private var editMode: EditMode = .inactive
	@State private var sorts: [SortCard] = [.newestToOldest]
	@State private var selectedLanguages: Set<String> = []
	@State private var showEditMode: Bool = false
	@State private var showNewCard: Bool = false
	@State private var showNewDeck: Bool = false
	@State private var showDeleteCard: Bool = false
	@State private var showSelectedCards: Bool = false
	@State private var showSafariExtension: Bool = false
	@State private var showBackLanguage: Bool = false
	@State private var showInvert: Bool = false
	
	private var filteredCards: [Card] {
		
		let filtered: [Card]
		
		if selectedLanguages.isEmpty {
			filtered = cards
		} else {
			filtered = cards.filter { selectedLanguages.contains($0.frontLanguage.code) || selectedLanguages.contains($0.backLanguage.code)
			}
		}
		return filtered.sorted(using: sorts.map(\.descriptor))
	}
	
	var body: some View {
		NavigationStack {
			List(selection: $selection) {
				ForEach(filteredCards) { card in
					VStack(alignment: .leading) {
						Button {
							Debug.print(level: .info, card: card)
							selectedCard = card
							showCard = true
						} label: {
							VStack(alignment: .leading, spacing: 5) {
								Text(showInvert ? card.backEntry : card.frontEntry)
									.font(.subheadline)
								if !showBackLanguage {
									Text(showInvert ? card.frontEntry : card.backEntry)
										.font(.subheadline)
										.foregroundStyle(.secondary)
								}
							}
						}
						.contextMenu {
							Button(role: .destructive) {
								item = card
								showDeleteCard.toggle()
							} label: {
								Label("Delete from Library", systemImage: "trash")
							}
						}
					}
					.listRowInsets(EdgeInsets(top: 11, leading: 15, bottom: 11, trailing: 15))
					.tag(card)
				}
			}
			.toolbar { toolbar }
			.animation(.easeInOut(duration: 0.15), value: selection.isEmpty)
			.animation(.easeInOut(duration: 0.15), value: editMode)
			.environment(\.editMode, $editMode)
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
			.sheet(isPresented: $showNewCard) {
				NewCardView()
					.presentationDetents([.fraction(Constants.heightOfANewCard), .large])
					.presentationDragIndicator(.visible)
			}
			.sheet(isPresented: $showNewDeck) {
				NewDeckView()
					.presentationDetents([.fraction(Constants.heightOfANewDeck), .large])
					.presentationDragIndicator(.visible)
			}
			.alert("Are you sure you want to delete this card from your library?", isPresented: $showDeleteCard) {
				Button("Remove", role: .destructive) {
					if let item {
						modelContext.delete(item)
					}
				}
				Button("Cancel", role: .cancel) { }
			}
			.alert("Selected Cards", isPresented: $showSelectedCards) {
				Button("Delete", role: .destructive) {
					deleteSelection()
					toggleEditMode()
				}
			} message: {
				Text("Are you sure you want to delete the selection?")
			}
			.listStyle(.plain)
		}
	}
}

/// Methods of CardsView.
fileprivate extension CardsView {
	
	private func deleteSelection() {
		for card in selection {
			modelContext.delete(card)
		}
		selection.removeAll()
	}
	
	private func toggleEditMode() {
		guard !showEditMode else { return }
		showEditMode.toggle()
		if editMode == .active {
			editMode = .inactive
			selection.removeAll()
		} else {
			editMode = .active
		}
		Task {
			try? await Task.sleep(for: .milliseconds(250))
			showEditMode.toggle()
		}
	}
}

fileprivate extension CardsView {
	
	func toggleSort(first: SortCard, second: SortCard) {
		
		if sorts.contains(first) {
			sorts.removeAll { $0 == first }
			if !sorts.contains(second) {
				sorts.insert(second, at: 0)
			}
		} else {
			sorts.removeAll { $0 == second }
			if !sorts.contains(first) {
				sorts.insert(first, at: 0)
			}
		}
	}
}

/// Toolbar.
fileprivate extension CardsView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			if !selection.isEmpty {
				Button(role: .destructive) {
					showSelectedCards.toggle()
				} label: {
					Text("Delete (\(selection.count))")
						.foregroundStyle(.red)
				}
			}
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				toggleEditMode()
			} label: {
				if editMode.isEditing == true {
					Text("Cancel")
				} else {
					Text("Select")
				}
			}
		}
		ToolbarSpacer(.fixed, placement: .topBarTrailing)
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				Button {
					showNewCard.toggle()
				} label: {
					Label("New Card", systemImage: "plus.square.fill.on.square.fill")
				}
				Button {
					showNewDeck.toggle()
				} label: {
					Label("New Deck", systemImage: "rectangle.stack.badge.play")
				}
				Section {
					Button {
						showInvert.toggle()
					} label: {
						Label {
							Text("Invert")
						} icon: {
							Image(systemName: "checkmark")
								.hidden(showInvert ? false : true)
						}
						Text(showInvert ? "Inverted" : "Normal")
							.font(.caption)
					}
					Button {
						showBackLanguage.toggle()
					} label: {
						Label("Hide", systemImage: showBackLanguage ? "eye.slash" : "eye")
						Text(showBackLanguage ? "Hidden" : "Visible")
							.font(.caption)
					}
				}
				Section {
					Button {
						toggleSort(first: .newestToOldest, second: .oldestToNewest)
					} label: {
						Label("Date", systemImage: sorts.contains(.newestToOldest) ? "text.line.first.and.arrowtriangle.forward" : "text.line.last.and.arrowtriangle.forward")
						Text(sorts.contains(.newestToOldest) ? "Newest to Oldest" : "Oldest to Newest")
					}
					Button {
						toggleSort(first: .alphabeticalAscending, second: .alphabeticalDescending)
					} label: {
						Label("Name", systemImage: sorts.contains(.alphabeticalAscending) ? "text.line.first.and.arrowtriangle.forward" : "text.line.last.and.arrowtriangle.forward")
						Text(sorts.contains(.alphabeticalAscending) ? "Ascending" : "Descending")
					}
				}
				Menu {
					ForEach(Language.codes, id: \.self) { language in
						Button {
							if selectedLanguages.contains(language) {
								selectedLanguages.remove(language)
							} else {
								selectedLanguages.insert(language)
							}
						} label: {
							Label {
								Text("\(language)")
							} icon: {
								Image(systemName: "checkmark")
									.hidden(!selectedLanguages.contains(language))
							}
						}
					}
				} label: {
					Label("Languages", systemImage: "bubble.left.and.bubble.right.fill")
				}
			} label: {
				Label("Options", systemImage: "ellipsis")
			}
		}
	}
}

#Preview {
	
	do {
		let container = try ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		let context = container.mainContext
		context.insert(Card(
			frontEntry: "dig in hiogjsodklhk",
			backEntry: "mangez!",
			frontLanguage: .en_US,
			backLanguage: .fr_FR
		))
		context.insert(Card(
			frontEntry: "hello",
			backEntry: "bonjourj kjj kksdhkldh ",
			frontLanguage: .en_US,
			backLanguage: .fr_FR
		))
		return CardsView()
			.modelContainer(container)
	}  catch {
		return Text("Failed to create preview: \(error.localizedDescription)")
	}
}
