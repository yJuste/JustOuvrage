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
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@State private var search: String = ""
	@State private var showCreationCardSheet: Bool = false
	
	var body: some View {
		List(cards) { card in
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
		}
		.listStyle(.plain)
		.searchable(text: $search, prompt: "Search")
		.toolbar {
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
						showCreationCardSheet.toggle()
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
		.sheet(isPresented: $showCreationCardSheet) {
			NewCardView()
		}
	}
}

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
