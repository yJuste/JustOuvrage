//
//  DecksView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/26/26.
//

import SwiftUI
import SwiftData

// MARK: Protect 'All Deck'

/// A view that shows every deck.
/// External Dependencies: Deck, FileImageStorage, DeckView, NewCardView, NewDeckView
struct DecksView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.dismiss) private var dismiss
	@Namespace private var namespace
	
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@Bindable private var preferences: Preferences = .unique
	@State private var item: Deck?
	@State private var selection: Set<Deck> = []
	@State private var selectedDeck: Deck?
	@State private var showDeck: Bool = false
	@State private var editMode: EditMode = .inactive
	@State private var sorts: [SortDeck] = Preferences.unique.sortDecks
	@State private var showDepiction: Bool = Preferences.unique.visibleDecks
	@State private var showEditMode: Bool = false
	@State private var showNewCard: Bool = false
	@State private var showNewDeck: Bool = false
	@State private var showDeleteDeck: Bool = false
	@State private var showSelectedDecks: Bool = false
	@State private var showMetaData: Bool = false
	
	private var filteredDecks: [Deck] {
		decks.sorted(using: sorts.map(\.descriptor))
	}
	
	var body: some View {
		NavigationStack {
			List(selection: $selection) {
				ForEach(filteredDecks) { deck in
					VStack(alignment: .leading) {
						Button {
							selectedDeck = deck
							showDeck = true
							deck.lastOpenedAt = .now
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
									if !showDepiction {
										Text(deck.depiction)
											.font(.system(size: 15, weight: .regular, design: .default))
											.foregroundStyle(.secondary)
											.lineLimit(2)
									}
								}
								Spacer()
								Menu {
									Button {
										showMetaData.toggle()
									} label: {
										Label {
											Text("View Metadata")
										} icon: {
											Image(systemName: "info.circle")
										}
										
									}
								} label: {
									Image(systemName: "ellipsis")
										.font(.system(size: 20, weight: .bold))
										.frame(width: 40, height: 40)
										.background (Circle().fill(.background))
								}
								.padding(.trailing, 10)
								.buttonStyle(.plain)
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
									.clipShape(RoundedRectangle(cornerRadius: 15))
								VStack(alignment: .leading, spacing: 2) {
									Text(deck.name)
										.font(.system(size: 20, weight: .bold, design: .default))
									Text(deck.depiction)
										.font(.system(size: 20, weight: .regular, design: .default))
										.foregroundStyle(.secondary)
								}
								.lineLimit(1)
								.frame(width: 280, alignment: .leading)
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
						.presentationDetents([.fraction(Constants.heightOfADeck[0]), .large])
						.presentationBackgroundInteraction(.enabled)
						.presentationDragIndicator(.visible)
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
			.alert("Delete Deck", isPresented: $showDeleteDeck) {
				Button("Remove", role: .destructive) {
					if let item {
						modelContext.delete(item)
					}
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Are you sure you want to delete this deck from your library?")
			}
			.alert("Selected Decks", isPresented: $showSelectedDecks) {
				Button("Delete", role: .destructive) { deleteSelection(); toggleEditMode() }
			} message: {
				Text("Are you sure you want to delete all the selection?")
			}
			.alert("Metadata for decks is not implemented yet.", isPresented: $showMetaData) {
				Button("OK", role: .cancel) { }
			}
			.listStyle(.plain)
		}
	}
}

/// Methods of DecksView.
fileprivate extension DecksView {
	
	private func deleteSelection() {
		for deck in selection {
			modelContext.delete(deck)
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

fileprivate extension DecksView {
	
	func toggleSort(first: SortDeck, second: SortDeck) {
		
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
		preferences.sortDecks = sorts
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
						showDepiction.toggle()
						preferences.visibleDecks = showDepiction
					} label: {
						Label("Hide", systemImage: showDepiction ? "eye.slash" : "eye")
						Text(showDepiction ? "Hidden" : "Visible")
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
	context.insert(Deck(name: "Hellojfkdjk fkdfkhsfkhd hfkdhf ksdhfk kfhsk hshdf khdfkhfksdh kh", image: "deck"))
	context.insert(Deck(name: "Hello", image: "deck"))
	context.insert(Deck(name: "Hello", image: "deck"))
	context.insert(Deck(name: "Hello", image: "deck"))
	let all = Deck(name: "All", image: "deck")
	context.insert(all)
	return DecksView()
		.modelContainer(container)
		.environment(FileImageStorage())
}
