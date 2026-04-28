//
//  LibraryView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/26/26.
//

import SwiftUI
import SwiftData

struct LibraryView: View {
	
	@Environment(FileImageStorage.self) var storage
	@Environment(\.dismiss) private var dismiss
	@Namespace private var namespace
	
	@Query(sort: \Deck.lastOpenedAt, order: .reverse) private var decks: [Deck]
	
	@State private var selectedDeck: Deck?
	@State private var showDeck: Bool = false
	
	@State private var showNewCard: Bool = false
	@State private var showNewDeck: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					NavigationLink {
						CardsView()
							.onAppear {
								showDeck = false
							}
					} label: {
						Label("Cards", systemImage: "text.pad.header")
					}
					NavigationLink {
						DecksView()
							.onAppear() {
								showDeck = false
							}
					} label: {
						Label("Decks", systemImage: "rectangle.stack.fill")
					}
				}
				Section {
					Text("Recently Opened")
						.font(.system(size: 23, weight: .semibold))
						.foregroundStyle(.primary)
						.listRowSeparator(.hidden)
						.padding(.top, 5)
						.padding(.bottom, -20)
						.padding(.leading, 3)
				}
				Section {
					LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
						ForEach(decks) { deck in
							Button {
								selectedDeck = deck
								showDeck = true
							} label: {
								VStack(alignment: .leading, spacing: 6) {
									Image(image: deck.image, storage: storage)
										.resizable()
										.scaledToFill()
										.frame(width: 162, height: 162)
										.aspectRatio(1, contentMode: .fill)
										.clipped()
										.clipShape(RoundedRectangle(cornerRadius: 8))
										.matchedTransitionSource(id: deck.id, in: namespace)
									VStack(alignment: .leading) {
										Text(deck.name)
											.font(.system(size: 16, weight: .semibold, design: .default))
											.lineLimit(1)
										Text(deck.depiction)
											.font(.system(size: 16, weight: .regular, design: .default))
											.foregroundStyle(.secondary)
											.lineLimit(1)
									}
									.padding(.bottom, 9)
								}
							}
							.buttonStyle(.plain)
						}
					}
					.listRowSeparator(.hidden)
					.padding(.horizontal, 4)
					.padding(.top, -3)
				}
			}
			.sheet(isPresented: $showDeck) {
				if let _ = selectedDeck {
					DeckView(deck: Binding(get: { selectedDeck! }, set: { selectedDeck = $0 }), namespace: namespace)
						.presentationDetents([.height(320), .large])
						.presentationBackgroundInteraction(.enabled)
						.presentationDragIndicator(.hidden)
				}
			}
			.toolbar { toolbar }
			.navigationTitle("Library")
			.toolbarTitleDisplayMode(.inlineLarge)
			.listStyle(.plain)
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
		}
	}
}

private extension LibraryView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		
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
				.compositingGroup()
			} label: {
				Image(systemName: "ellipsis")
			}
		}
		ToolbarSpacer(.fixed, placement: .topBarTrailing)
		ToolbarItem(placement: .topBarTrailing) {
			Image(.profileMan)
				.resizable()
				.frame(width: 36, height: 36)
				.clipShape(Circle())
				.onTapGesture {
					// profile
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
	
	return LibraryView()
		.modelContainer(container)
		.environment(FileImageStorage())
}
