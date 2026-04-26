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
	
	@State private var item: Deck?
	
	@State private var showCard: Bool = false
	@State private var showDeck: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				Section { // categories
					NavigationLink {
						CardsView()
					} label: {
						Label("Cards", systemImage: "text.pad.header")
					}
					NavigationLink {
						DecksView()
					} label: {
						Label("Decks", systemImage: "rectangle.stack.fill")
					}
				}
				Section { // sub-title
					Text("Recently Opened")
						.font(.system(size: 23, weight: .semibold))
						.foregroundStyle(.primary)
						.listRowSeparator(.hidden)
						.padding(.top, 5)
						.padding(.bottom, -20)
						.padding(.leading, 3)
				}
				Section { // album-decks
					LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10)], spacing: 10) {
						ForEach(decks) { deck in
							Button {
								item = deck
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
										Text(deck.depiction)
											.font(.system(size: 16, weight: .regular, design: .default))
											.foregroundStyle(.secondary)
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
			.toolbar { toolbar }
			.navigationTitle("Library")
			.toolbarTitleDisplayMode(.inlineLarge)
			.fullScreenCover(item: $item) { deck in
				LibraryDeckView(deck: deck, namespace: namespace)
			}
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

private extension LibraryView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		
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
