//
//  HomeView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/16/26.
//

import SwiftUI

/// A view where all the cards are displayed.
struct HomeView: View {

	let cards: [Card]

	@State private var showExpand: Bool = false
	@State private var showMenu: Bool = false
	@State private var search: String = ""
	@State private var sortLanguage = [
		SortDescriptor(\Card.frontLanguageCode.rawValue),
		SortDescriptor(\Card.backEntry),
	]

	var filteredCards: [Card] {
		if search.isEmpty {
			return cards
		} else {
			return cards.filter {
				$0.frontEntry.localizedCaseInsensitiveContains(search)
				|| $0.backEntry.localizedCaseInsensitiveContains(search)
			}
		}
	}

	var body: some View {
		List(filteredCards) { card in
			VStack(alignment: .leading) {
				Button {
					showExpand.toggle()
				} label: {
					VStack(alignment: .leading, spacing: 5) {
						Text(card.frontEntry)
							.font(.subheadline)
						Text(card.backEntry)
							.font(.subheadline)
							.foregroundStyle(.gray)
					}
				}
				if showExpand {
					Text(card.backEntry)
						.font(.subheadline)
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
						print("Settings")
					} label: {
						Label("Settings", systemImage: "gear")
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
}

#Preview {
	
	let cards: [Card] = (1...5).map { i in
			Card(frontEntry: "Front \(i)", backEntry: "Back \(i)", frontLanguageCode: .en_US, backLanguageCode: .en_US)
	}
	
	struct HomePreview: View {

		@State var search: String = ""
		@State var showExpand: Bool = false
		
		let cards: [Card]
		
		var body: some View {
			NavigationStack {
				HomeView(cards: cards)
			}
		}
	}
	
	return HomePreview(cards: cards)
}

