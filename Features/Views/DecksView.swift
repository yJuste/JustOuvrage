//
//  DecksView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/26/26.
//

import SwiftUI
import SwiftData

struct DecksView: View {
	
	@Environment(\.modelContext) private var context
	@Environment(FileImageStorage.self) var storage
	@Environment(\.dismiss) private var dismiss
	@Namespace private var namespace
	
	@Query(sort: \Deck.lastOpenedAt, order: .reverse) private var decks: [Deck]
	
	@State private var item: Deck?
	@State private var multiSelection: Set<Deck> = []
	
	@State private var editMode: EditMode = .inactive
	@State private var isTogglingEditMode = false
	
	@State private var showCard: Bool = false
	@State private var showDeck: Bool = false
	
	var body: some View {
		NavigationStack {
			List(selection: $multiSelection) {
				ForEach(decks) { deck in
					LazyVStack(alignment: .leading) {
						Button {
							//
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
					}
					.listRowInsets(EdgeInsets(top: 11, leading: 15, bottom: 11, trailing: 15))
					.tag(deck)
				}
			}
			.toolbar { toolbar }
			.animation(.easeInOut(duration: 0.15), value: multiSelection.isEmpty)
			.animation(.easeInOut(duration: 0.15), value: editMode)
			.environment(\.editMode, $editMode)
			.sheet(isPresented: $showCard) {
				NewCardView()
					.presentationDetents([.height(520), .large])
					.presentationDragIndicator(.visible)
			}
			.sheet(isPresented: $showDeck) {
				NewDeckView()
					.presentationDetents([.medium, .large])
					.presentationDragIndicator(.visible)
			}
			.listStyle(.plain)
		}
	}
}

/// Methods of DecksView.
private extension DecksView {
	
	private func deleteSelection() {
		
		for card in multiSelection {
			context.delete(card)
		}
		multiSelection.removeAll()
	}
	
	private func toggleEditMode() {
		
		guard !isTogglingEditMode else { return }
		isTogglingEditMode.toggle()
		if editMode == .active {
			editMode = .inactive
			multiSelection.removeAll()
		} else {
			editMode = .active
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			isTogglingEditMode.toggle()
		}
	}
}

/// Toolbar.
private extension DecksView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		
		ToolbarItem(placement: .topBarLeading) {
			if !multiSelection.isEmpty {
				Button(role: .destructive) {
					deleteSelection()
					toggleEditMode()
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
						showCard.toggle()
					} label: {
						Label("New Card", systemImage: "plus.square.fill.on.square.fill")
					}
					Button {
						showDeck.toggle()
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
	
	let container = try! ModelContainer(
		for: Deck.self,
		configurations: ModelConfiguration(isStoredInMemoryOnly: true)
	)
	
	let context = container.mainContext
	
	// seed data
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
