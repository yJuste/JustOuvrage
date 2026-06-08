//
//  CardsView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/26/26.
//

import SwiftUI
import SwiftData

/// A view where all the cards are displayed.
/// External Dependencies: Card, Constants, CardView, NewCardView, NewDeckView
struct CardsView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@Bindable private var preferences: Preferences = .unique
	@State private var selectedCard: Card?
	@State private var selection: Set<Card> = []
	@State private var editMode: EditMode = .inactive
	@State private var selectedLanguages: Set<String> = []
	@State private var sorts: [SortCard] = Preferences.unique.sortCards
	@State private var filterVisible: Bool = Preferences.unique.visibleCards
	@State private var filterInvert: Bool = Preferences.unique.invertCards
	@State private var languageFilterCards: LanguageFilter = Preferences.unique.languageFilterCards
	@State private var showCard: Bool = false
	@State private var showEditMode: Bool = false
	@State private var showNewCard: Bool = false
	@State private var showNewDeck: Bool = false
	@State private var showDeleteCard: Bool = false
	@State private var showSelectedCards: Bool = false
	@State private var showMetaData: Bool = false
	@State private var showRecording: Bool = false
	@State private var showDecksToCard: Bool = false
	@State private var showEditCard: Bool = false
	
	private var filteredCards: [Card] {
		let filtered: [Card]
		if selectedLanguages.isEmpty {
			filtered = cards
		} else {
			let selected = Set(selectedLanguages)
			filtered = cards.filter { card in
				let front = card.frontLanguage.code
				let back = card.backLanguage.code
				let match = selected.contains(front) || selected.contains(back)
				let same = front == back && selected.contains(front)
				switch languageFilterCards {
				case .atLeastOne: return match
				case .justOne: if same { return false }; return match
				case .needBoth: return same
				}
			}
		}
		return filtered.sorted { lhs, rhs in
			for sort in sorts {
				if let result = sort.compare(lhs, rhs) {
					return result == .orderedAscending
				}
			}
			return false
		}
	}
	
	private var dismissItems: [Binding<Bool>] {
		[$showCard, $showEditMode, $showNewCard, $showNewDeck, $showSelectedCards, $showMetaData, $showRecording, $showDecksToCard, $showEditCard]
	}
	
	var body: some View {
		NavigationStack {
			List(selection: $selection) {
				ForEach(filteredCards) { card in
					let front = card.frontEntry
					let back = card.backEntry
					VStack(alignment: .leading) {
						Button {
							selectedCard = card
							dismissItems.showOnly($showCard)
						} label: {
							HStack {
								VStack(alignment: .leading, spacing: 5) {
									Text(filterInvert ? back : front)
										.font(.subheadline)
									if !filterVisible {
										Text(filterInvert ? front : back)
											.font(.subheadline)
											.foregroundStyle(.secondary)
									}
								}
								Spacer()
								Menu {
									options(for: card)
								} label: {
									Image(systemName: "ellipsis")
										.font(.system(size: 20, weight: .bold))
										.frame(width: 41, height: 41)
										.background (Circle().fill(.clear))
								}
								.padding(.trailing, 10)
								.buttonStyle(.plain)
							}
						}
						.contextMenu {
							options(for: card)
						}
					}
					.tag(card)
					.listRowInsets(EdgeInsets(top: 11, leading: 15, bottom: 11, trailing: 15))
				}
			}
			.onChange(of: preferences.languageFilterCards) { _, newValue in
				languageFilterCards = newValue
			}
			.toolbar { toolbar }
			.tint(nil)
			.animation(.easeInOut(duration: 0.15), value: selection.isEmpty)
			.animation(.easeInOut(duration: 0.15), value: editMode)
			.listStyle(.plain)
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
			.sheet(isPresented: $showEditCard) {
				if let card = selectedCard {
					EditCardView(title: "Edit Card", card: card)
				}
			}
			.sheet(isPresented: $showDecksToCard) {
				if let card = selectedCard {
					DecksToCardView(card: card)
				}
			}
			.sheet(isPresented: $showRecording) {
				if let card = selectedCard {
					RecordingView(card: card)
						.presentationDetents([
							.fraction(Constants.heightOfARecording[0]),
							.fraction(Constants.heightOfARecording[1])
						])
						.presentationBackgroundInteraction(.enabled)
				}
			}
			.sheet(isPresented: $showMetaData) {
				if let card = selectedCard {
					CardMetaDataView(card: card)
						.presentationDetents([
							.fraction(Constants.heightOfAMetaData[0]),
							.fraction(Constants.heightOfAMetaData[1])
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
				Button("Delete", role: .destructive) {
					if let selectedCard {
						modelContext.delete(selectedCard)
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
			.environment(\.editMode, $editMode)
		}
	}
}

/// Methods of CardsView.
fileprivate extension CardsView {
	
	@ViewBuilder private func options(for card: Card) -> some View {
		Section {
			Button {
				selectedCard = card
				dismissItems.showOnly($showCard)
			} label: {
				Label(card.frontEntry, systemImage: "filemenu.and.selection")
				Text(card.backEntry)
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
		Button {
			selectedCard = card
			dismissItems.showOnly($showEditCard)
		} label: {
			Label("Edit", systemImage: "slider.horizontal.3")
		}
		Button {
			selectedCard = card
			dismissItems.showOnly($showDecksToCard)
		} label: {
			Label("Add to decks", systemImage: "rectangle.stack")
		}
		Button {
			selectedCard = card
			dismissItems.showOnly($showRecording)
		} label: {
			Label("Record audio", systemImage: "microphone")
		}
		Button {
			let newCard = Card(frontEntry: card.frontEntry, backEntry: card.backEntry, frontLanguage: card.frontLanguage, backLanguage: card.backLanguage, author: card.author)
			newCard.decks = card.decks
			newCard.frontRecording = card.frontRecording
			newCard.backRecording = card.backRecording
			newCard.leitnerScore = card.leitnerScore
			newCard.nextLeitnerAt = card.nextLeitnerAt
			modelContext.insert(newCard)
		} label: {
			Label("Duplicate", systemImage: "rectangle.portrait.on.rectangle.portrait.angled")
		}
		Section {
			Button {
				selectedCard = card
				dismissItems.showOnly($showMetaData)
			} label: {
				Label("View Metadata", systemImage: "info.circle")
			}
		}
		Section {
			Button(role: .destructive) {
				selectedCard = card
				showDeleteCard.toggle()
			} label: {
				Label("Delete from Library", systemImage: "trash")
			}
		}
	}
	
	private func deleteSelection() {
		for card in selection {
			modelContext.delete(card)
		}
		selection.removeAll()
	}
}

/// Methods of CardsView. (toggle)
fileprivate extension CardsView {
	
	private func toggleEditMode() {
		guard !showEditMode else { return }
		dismissItems.toggleOnly($showEditMode)
		if editMode == .active {
			editMode = .inactive
			selection.removeAll()
		} else {
			editMode = .active
		}
		Task {
			try? await Task.sleep(for: .milliseconds(250))
			dismissItems.toggleOnly($showEditMode)
		}
	}
	
	private func toggleSort(first: SortCard, second: SortCard) {
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
		preferences.sortCards = sorts
	}
}

/// Toolbar.
fileprivate extension CardsView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			if !selection.isEmpty {
				Button(role: .destructive) {
					dismissItems.showOnly($showSelectedCards)
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
				if editMode.isEditing {
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
					dismissItems.showOnly($showNewCard)
				} label: {
					Label("New Card", systemImage: "plus.rectangle.portrait")
				}
				Button {
					dismissItems.showOnly($showNewCard)
				} label: {
					Label("New Deck", systemImage: "plus.rectangle.on.rectangle")
				}
				Section {
					Button {
						filterInvert.toggle()
						preferences.invertCards = filterInvert
					} label: {
						Label("Invert", systemImage: filterInvert ? "square.2.layers.3d.bottom.filled" : "square.2.layers.3d.top.filled")
						Text(filterInvert ? "Inverted" : "Normal")
							.font(.caption)
					}
					Button {
						filterVisible.toggle()
						preferences.visibleCards = filterVisible
					} label: {
						Label("Hide", systemImage: filterVisible ? "eye.slash" : "eye")
						Text(filterVisible ? "Hidden" : "Visible")
							.font(.caption)
					}
				}
				Section {
					Button {
						toggleSort(first: .newestToOldest, second: .oldestToNewest)
					} label: {
						let contain = sorts.contains(.newestToOldest)
						Label("Date", systemImage: contain ? "text.line.first.and.arrowtriangle.forward" : "text.line.last.and.arrowtriangle.forward")
						Text(contain ? "Newest to Oldest" : "Oldest to Newest")
					}
					Button {
						toggleSort(first: .alphabeticalAscending, second: .alphabeticalDescending)
					} label: {
						let contain = sorts.contains(.alphabeticalAscending)
						Label("Name", systemImage: contain ? "text.line.first.and.arrowtriangle.forward" : "text.line.last.and.arrowtriangle.forward")
						Text(contain ? "Ascending" : "Descending")
					}
				}
				Section {
					Button {
						switch languageFilterCards {
						case .atLeastOne: preferences.languageFilterCards = .justOne
						case .justOne: preferences.languageFilterCards = .needBoth
						case .needBoth: preferences.languageFilterCards = .atLeastOne
						}
					} label: {
						Label(languageFilterCards.title, systemImage: languageFilterCards.icon)
					}
					ForEach(Language.codes, id: \.self) { language in
						let contain = selectedLanguages.contains(language)
						Button {
							if contain {
								selectedLanguages.remove(language)
							} else {
								selectedLanguages.insert(language)
							}
						} label: {
							Label {
								Text(language)
							} icon: {
								Image(systemName: "checkmark")
									.hidden(!contain)
							}
						}
					}
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
			backLanguage: .fr_FR,
			author: "yJuste"
		))
		context.insert(Card(
			frontEntry: "hello",
			backEntry: "bonjourj kjj kksdhkldh ",
			frontLanguage: .en_US,
			backLanguage: .fr_FR,
			author: "yJuste"
		))
		return CardsView()
			.modelContainer(container)
	}  catch {
		return Text("Failed to create preview: \(error.localizedDescription)")
	}
}
