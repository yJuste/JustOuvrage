//
//  LibraryView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/26/26.
//

import SwiftUI
import SwiftData

/// A view that shows the Library hub.
/// External Dependencies: Deck, FileImageStorage, CardsView, DecksView, DeckView, NewCardView, NewDeckView
struct LibraryView: View {
	
	@Environment(FileImageStorage.self) var storage
	@Environment(\.dismiss) private var dismiss
	@Namespace private var namespace
	
	@Query(sort: [SortDescriptor(\Deck.lastOpenedAt, order: .reverse), SortDescriptor(\Deck.createdAt, order: .reverse)]) private var decks: [Deck]
	
	@State private var selectedDeck: Deck?
	@State private var showNewCard: Bool = false
	@State private var showNewDeck: Bool = false
	@State private var showProfile: Bool = false
	
	var body: some View {
		NavigationStack {
			List {
				Section {
					NavigationLink {
						CardsView()
					} label: {
						Label("Cards", systemImage: "rectangle.portrait.on.rectangle.portrait.fill")
					}
					NavigationLink {
						DecksView()
					} label: {
						Label("Decks", systemImage: "rectangle.stack.fill")
					}
				} /// ``links to every card/deck``
				Section {
					Text("Recently Opened")
						.font(.system(size: 23, weight: .semibold))
						.padding(EdgeInsets(top: 5, leading: 3, bottom: -20, trailing: 0))
					LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 10, alignment: .top)], spacing: 10) {
						ForEach(decks) { deck in
							Button {
								selectedDeck = deck
								deck.lastOpenedAt = .now
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
										Text(deck.depiction)
											.foregroundStyle(.secondary)
									}
									.font(.system(size: 16))
									.lineLimit(1)
									.padding(.bottom, 9)
								}
							}
							.buttonStyle(.plain)
						}
					}
					.listRowSeparator(.hidden)
					.padding(EdgeInsets(top: -3, leading: 4, bottom: 0, trailing: 4))
				} /// ``recent decks``
			}
			.toolbar { toolbar }
			.navigationDestination(item: $selectedDeck) { deck in
				DeckView(deck: deck, namespace: namespace)
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
			.sheet(isPresented: $showProfile) {
				ProfileView()
					.presentationDetents([.large])
					.presentationDragIndicator(.hidden)
			}
			.navigationTitle("Library")
			.toolbarTitleDisplayMode(.inlineLarge)
			.listStyle(.plain)
		}
	}
}

/// Toolbar.
fileprivate extension LibraryView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
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
			} label: {
				Label("Add", systemImage: "square.fill.text.grid.1x2")
			}
			.tint(nil)
		}
		ToolbarSpacer(.fixed, placement: .topBarTrailing)
		ToolbarItem(placement: .topBarTrailing) {
			Image(image: Preferences.unique.profileImage, storage: storage, defaultAsset: Constants.defaultProfileImage)
				.resizable()
				.scaledToFill()
				.frame(width: 36, height: 36)
				.clipShape(Circle())
				.onTapGesture {
					showProfile.toggle()
				}
		}
	}
}

#Preview {
	
	let container = try! ModelContainer(for: Deck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
	let context = container.mainContext
	context.insert(Deck(name: "Hello", image: "deck", author: "yJuste"))
	context.insert(Deck(name: "Lucas", image: "deck", author: "yJuste"))
	context.insert(Deck(name: "I love you", image: "deck", author: "yJuste"))
	context.insert(Deck(name: "Hello", image: "deck", author: "yJuste"))
	return LibraryView()
		.modelContainer(container)
		.environment(FileImageStorage())
}
