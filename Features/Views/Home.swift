//
//  Home.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/16/26.
//

import SwiftUI

/// A view where all the cards are displayed.
struct Home: View {
	
	let filteredCards: [Card]
	
	@Binding var showExpand: Bool
	@Binding var search: String
	
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
		.searchable(text: $search, placement: .sidebar, prompt: "Search words...")
	}
}

#Preview {
	
	let languages: [Language] = [
		.en_US,
		.en_GB,
		.fr_FR,
		.es_ES]
	
	let cards: [Card] = (1...20).map { i in
		Card(
			name: "Words \(i)",
			definition: "Definition \(i)",
			language: languages[i % languages.count])
	}
	
	struct HomePreview: View {

		@State var search: String = ""
		@State var showExpand: Bool = false
		
		let cards: [Card]
		
		var body: some View {
			NavigationStack {
				Home(
					filteredCards: cards,
					showExpand: $showExpand,
					search: $search)
			}
		}
	}
	
	return HomePreview(cards: cards)
}
