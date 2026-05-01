//
//  DecksView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/26/26.
//

import SwiftUI
import SwiftData

/// A view that shows every deck.
/// External Dependencies: Deck, FileImageStorage, DeckView, NewCardView, NewDeckView
struct DecksView: View {
	
	@Environment(\.modelContext) private var context
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.dismiss) private var dismiss
	@Namespace private var namespace
	
	@Query(sort: \Deck.lastOpenedAt, order: .reverse) private var decks: [Deck]
	
	@State private var item: Deck?
	@State private var selection: Set<Deck> = []
	@State private var selectedDeck: Deck?
	@State private var showDeck: Bool = false
	@State private var editMode: EditMode = .inactive
	@State private var showEditMode: Bool = false
	@State private var showNewCard: Bool = false
	@State private var showNewDeck: Bool = false
	@State private var showDeleteDeck: Bool = false
	@State private var showSelectedDecks: Bool = false
	
	var body: some View {
		NavigationStack {
			List(selection: $selection) {
				ForEach(decks) { deck in
					VStack(alignment: .leading) {
						Button {
							selectedDeck = deck
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
										.foregroundStyle(Color.primary)
								}
								.padding(.trailing, 10)
							}
						}
						.contextMenu {
							Button(role: .destructive) {
								item = deck
								showDeleteDeck.toggle()
							} label: {
								Label("Delete from Library", systemImage: "trash")
							}
						} preview: {
							VStack(alignment: .leading, spacing: 10) {
								Image(image: deck.image, storage: storage)
									.resizable()
									.scaledToFill()
									.frame(width: 280, height: 280)
									.clipped()
									.clipShape(RoundedRectangle(cornerRadius: 15))
									.padding(.top, -5)
								VStack(alignment: .leading, spacing: 2) {
									Text(deck.name)
										.font(.system(size: 20, weight: .bold, design: .default))
									Text(deck.depiction)
										.font(.system(size: 20, weight: .regular, design: .default))
										.foregroundStyle(.secondary)
								}
							}
							.frame(width: 320, height: 370)
						}
					}
					.listRowInsets(EdgeInsets(top: 11, leading: 15, bottom: 11, trailing: 15))
					.tag(deck)
				}
			}
			.toolbar { toolbar }
			.animation(.easeInOut(duration: 0.15), value: selection.isEmpty)
			.animation(.easeInOut(duration: 0.15), value: editMode)
			.environment(\.editMode, $editMode)
			.sheet(isPresented: $showDeck) {
				if let deck = selectedDeck {
					DeckView(deck: deck, namespace: namespace)
						.presentationDetents([.height(320), .large])
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
			.alert("Are you sure you want to delete this deck from your library?", isPresented: $showDeleteDeck) {
				Button("Remove", role: .destructive) { if let item { context.delete(item) } }
				Button("Cancel", role: .cancel) { }
			}
			.alert("Selected Decks", isPresented: $showSelectedDecks) {
				Button("Delete", role: .destructive) { deleteSelection(); toggleEditMode() }
			} message: {
				Text("Are you sure you want to delete the selection?")
			}
			.listStyle(.plain)
		}
	}
}

/// Methods of DecksView.
fileprivate extension DecksView {
	
	private func deleteSelection() {
		for card in selection {
			context.delete(card)
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
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			showEditMode.toggle()
		}
	}
}

/// Toolbar.
fileprivate extension DecksView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			if !selection.isEmpty {
				Button(role: .destructive) {
					showSelectedDecks.toggle()
				} label: {
					Text("Delete (\(selection.count))")
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
	
	let container = try! ModelContainer(for: Deck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
	let context = container.mainContext
	context.insert(Deck(name: "Hello", image: "deck"))
	context.insert(Deck(name: "Lucas", image: "deck"))
	context.insert(Deck(name: "I love you", image: "deck"))
	context.insert(Deck(name: "Hello", image: "deck"))
	context.insert(Deck(name: "Hello", image: "deck"))
	context.insert(Deck(name: "Hello", image: "deck"))
	context.insert(Deck(name: "Hello", image: "deck"))
	context.insert(Deck(name: "Hello", image: "deck"))
	return DecksView()
		.modelContainer(container)
		.environment(FileImageStorage())
}
