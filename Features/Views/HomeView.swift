//
//  HomeView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/16/26.
//

import SwiftUI
import SwiftData

/// A view where all the cards are displayed.
/// External Dependencies: Card, NewCardView
struct HomeView: View {
	
	@Environment(\.modelContext) private var context
	@State private var editMode: EditMode = .inactive
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@State private var search: String = ""
	@State private var showNewCardSheet: Bool = false
	@State private var multiSelection: Set<Card> = []
	var isSelecting: Bool {
		editMode.isEditing
	}
	@State private var isTogglingEditMode = false
	
	var body: some View {
		
		List(selection: $multiSelection) {
			ForEach(cards) { card in
				VStack(alignment: .leading) {
					Button {
#if DEBUG
						print("FrontEntry: \(card.frontEntry)")
						print("BackEntry: \(card.backEntry)")
						print("FrontLanguage: \(card.frontLanguage)")
						print("BackLanguage: \(card.backLanguage)")
						print("LeitnerScore: \(card.leitnerScore)")
						print("Date created: \(card.createdAt)")
#endif
					} label: {
						VStack(alignment: .leading, spacing: 5) {
							Text(card.frontEntry)
								.font(.subheadline)
							Text(card.backEntry)
								.font(.subheadline)
								.foregroundStyle(.gray)
						}
					}
				}
				.listRowInsets(EdgeInsets(top: 11, leading: 15, bottom: 11, trailing: 15))
				.tag(card)
			}
		}
		.navigationTitle("Recents")
		.listStyle(.plain)
		//.searchable(text: $search, prompt: "Search")
		.toolbar { toolbar }
		.sheet(isPresented: $showNewCardSheet) {
			NewCardView()
		}
		.onChange(of: multiSelection) { oldValue, newValue in
			if newValue.isEmpty {
				print("Rien de selectionne.")
			} else {
				print("Selectionné oldValue: \(oldValue)")
				print("Selectionné newValue: \(newValue)")
			}
		}
		.animation(.easeInOut(duration: 0.2), value: editMode)
		.environment(\.editMode, $editMode)
	}
	
	private func deleteSelection() {
		
		for card in multiSelection {
			context.delete(card)
		}
		multiSelection.removeAll()
	}
	
	private func toggleEditMode() {
		
		guard !isTogglingEditMode else { return }
		isTogglingEditMode = true
		if editMode == .active {
			editMode = .inactive
			multiSelection.removeAll()
		} else {
			editMode = .active
		}
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			isTogglingEditMode = false
		}
	}
}

extension HomeView {
	
	@ToolbarContentBuilder var toolbar: some ToolbarContent {
		
		ToolbarItem(placement: .topBarLeading) {
			if !multiSelection.isEmpty {
				Button(role: .destructive) {
					deleteSelection()
				} label: {
					Text("Supprimer (\(multiSelection.count))")
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
	}
}

/// An extension that creates a nice light Interface.
extension HomeView {
	
	@ToolbarContentBuilder var lightToolbar: some ToolbarContent {
		
		ToolbarItem(placement: .topBarLeading) {
			if !multiSelection.isEmpty {
				Button(role: .destructive) {
					deleteSelection()
				} label: {
					Text("Supprimer (\(multiSelection.count))")
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
		ToolbarItem(placement: .bottomBar) {
			Menu {
				Button {
					print("Last 50")
				} label: {
					Label("Last 50", systemImage: "plus")
				}
			} label: {
				Image(systemName: "flag.pattern.checkered.2.crossed")
			}
		}
		ToolbarSpacer(.fixed, placement: .bottomBar)
		DefaultToolbarItem(kind: .search, placement: .bottomBar)
		ToolbarSpacer(.fixed, placement: .bottomBar)
		ToolbarItem(placement: .bottomBar) {
			Menu {
				Button {
					showNewCardSheet.toggle()
				} label: {
					Label("Add A New Card", systemImage: "plus")
				}
				Section {
					Button {
						print("Date")
					} label: {
						Label("Date", systemImage: "plus")
					}
					Button {
						print("Name")
					} label: {
						Label("Name", systemImage: "plus")
					}
					Button {
						print("Favorites")
					} label: {
						Label("Favorites", systemImage: "star")
					}
					Menu {
						Button {
							print("English")
						} label: {
							Label("English", systemImage: "flag")
						}
						Button {
							print("French")
						} label: {
							Label("French", systemImage: "flag")
						}
					} label: {
						Label("Languages", systemImage: "flag")
					}
				}
			} label: {
				Image(systemName: "circle.badge.plus")
			}
		}
		
	}
}

//	// Delete a Card on a List.
//	private func deleteCard(indexSet: IndexSet) {
//		for i in indexSet {
//			context.delete(cards[i])
//		}
//	}

//	// Move a Card on a List.
//	private func moveCard(indexSet: IndexSet, offset: Int) {
//		cards.move(fromOffsets: indexSet, toOffset: offset)
//	}

// Swipe L->R to show more
//		.swipeActions(edge: .leading) {
//			Button("Swipe Left") {
//
//			}
//		}

#Preview {
	do {
		let container = try ModelContainer(for: Card.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
		let context = container.mainContext
		context.insert(Card(
			frontEntry: "dig in",
			backEntry: "mangez!",
			frontLanguage: .en_US,
			backLanguage: .fr_FR
		))
		context.insert(Card(
			frontEntry: "hello",
			backEntry: "bonjour",
			frontLanguage: .en_US,
			backLanguage: .fr_FR
		))
		return HomeView()
			.modelContainer(container)
	}  catch {
		return Text("Failed to create preview: \(error.localizedDescription)")
	}
}
