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
	@State private var search: String = ""
	
	var filteredCards: [Card] {
		if search.isEmpty {
			return cards
		} else {
			return cards.filter {
				$0.name.localizedCaseInsensitiveContains(search)
				|| $0.definition.localizedCaseInsensitiveContains(search)
			}
		}
	}
	
	var body: some View {
		List(filteredCards) { card in
			VStack(alignment: .leading) {
				Button(action: { showExpand.toggle() }) {
					VStack(alignment: .leading, spacing: 2) {
						HStack {
							Text(card.name)
								.font(.headline)
							
							Spacer()
							
							Text(card.definition)
								.font(.subheadline)
								.foregroundStyle(.secondary)
						}
						
						if !card.context.isEmpty {
							Text(card.context)
								.font(.subheadline)
								.foregroundStyle(.gray)
						}
					}
				}
				if showExpand {
					Text("No way it works")
				}
			}
			.listRowInsets(EdgeInsets(top: 11, leading: 15, bottom: 11, trailing: 15))
		}
		.listStyle(.plain)
		.toolbar {
			ToolbarItem(placement: .bottomBar) {
				Button {
					print("plus")
				} label: {
					Image(systemName: "flag.pattern.checkered.2.crossed")
				}
			}
			
			ToolbarSpacer(.fixed, placement: .bottomBar)
			DefaultToolbarItem(kind: .search, placement: .bottomBar)
			ToolbarSpacer(.fixed, placement: .bottomBar)
			
			ToolbarItem(placement: .bottomBar) {
				Button {
					//
				} label: {
					Image(systemName: "circle.badge.plus")
				}
			}
		}
		.searchable(text: $search, prompt: "Search words...")
	}
}

#Preview {
	
	let languages: [Language] = Language.allCases

	let cards: [Card] = (1...20).map { i in
		Card(name: "Words \(i)", definition: "Definition \(i)", language: languages[i % languages.count])
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
