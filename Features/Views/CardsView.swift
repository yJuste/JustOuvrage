//
//  CardsView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/26/26.
//

import SwiftUI
import SwiftData
import os // MARK: debug

/// A view where all the cards are displayed.
/// External Dependencies: Card, NewCardView
struct CardsView: View {
	
	@Environment(\.modelContext) private var context
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@State private var item: Card?
	@State private var multiSelection: Set<Card> = []
	
	@State private var selectedCard: Card?
	@State private var showCard: Bool = false
	
	@State private var editMode: EditMode = .inactive
	@State private var showEditMode: Bool = false
	
	@State private var showNewCard: Bool = false
	@State private var showNewDeck: Bool = false
	@State private var showDeleteCard: Bool = false
	@State private var showSelectedCards: Bool = false
	@State private var showSafariExtension: Bool = false
	
	var body: some View {
		
		NavigationStack {
			List(selection: $multiSelection) {
				ForEach(cards) { card in
					VStack(alignment: .leading) {
						Button {
							Debug.print(level: .info, card: card)
							selectedCard = card
							showCard = true
						} label: {
							VStack(alignment: .leading, spacing: 5) {
								Text(card.frontEntry)
									.font(.subheadline)
								Text(card.backEntry)
									.font(.subheadline)
									.foregroundStyle(.gray)
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
			.animation(.easeInOut(duration: 0.15), value: multiSelection.isEmpty)
			.animation(.easeInOut(duration: 0.15), value: editMode)
			.environment(\.editMode, $editMode)
			.sheet(isPresented: $showCard) {
				if let card = selectedCard {
					CardView(card: card)
						.presentationDetents([.height(180)])
						.presentationBackgroundInteraction(.enabled)
						.presentationDragIndicator(.hidden)
				}
			}
			.sheet(isPresented: $showNewCard) {
				NewCardView()
					.presentationDetents([.height(520), .large])
					.presentationDragIndicator(.visible)
			}
			.sheet(isPresented: $showNewDeck) {
				NewDeckView()
					.presentationDetents([.medium, .large])
					.presentationDragIndicator(.visible)
			}
			.alert("Are you sure you want to delete this card from your library?", isPresented: $showDeleteCard) {
				Button("Remove", role: .destructive) {
					if let item {
						context.delete(item)
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
private extension CardsView {
	
	private func deleteSelection() {
		
		for card in multiSelection {
			context.delete(card)
		}
		multiSelection.removeAll()
	}
	
	private func toggleEditMode() {
		
		guard !showEditMode else { return }
		showEditMode.toggle()
		if editMode == .active {
			editMode = .inactive
			multiSelection.removeAll()
		} else {
			editMode = .active
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			showEditMode.toggle()
		}
	}
}

/// Toolbar.
private extension CardsView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		
		ToolbarItem(placement: .topBarLeading) {
			if !multiSelection.isEmpty {
				Button(role: .destructive) {
					showSelectedCards.toggle()
				} label: {
					Text("Delete (\(multiSelection.count))")
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
				} label: {
					Label("Add", systemImage: "square.fill.text.grid.1x2")
				}
				Section {
					Button {
						// Hide definition
					} label: {
						Label("Hide", systemImage: "eye")
						Text("Visible") // Hidden with eye.slash
							.font(.caption)
					}
				}
				Section {
					Button {
						// sort Date
					} label: {
						Label("Date", systemImage: "checkmark")
						Text("Newest to Oldest") // Oldest to Newest
							.font(.caption)
					}
					Button {
						// sort Name
					} label: {
						Image(systemName: "checkmark")
							.hidden(false)
						Text("Name")
						Text("Ascending") // Descending
							.font(.caption)
					}
				}
				Menu {
					Button {
						//
					} label: {
						Image(systemName: "checkmark")
							.hidden(false)
						Text("English")
					}
					Button {
						//
					} label: {
						Image(systemName: "checkmark")
							.hidden(true)
						Text("French")
					}
					Button {
						//
					} label: {
						Image(systemName: "checkmark")
							.hidden(false)
						Text("Spanish")
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
