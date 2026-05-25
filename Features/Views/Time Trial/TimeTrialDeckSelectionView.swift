//
//  TimeTrialDeckSelectionView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/23/26.
//

import SwiftUI

struct TimeTrialDeckSelectionView: View {
	
	@Binding var selectedDeck: Deck?
	let decks: [Deck]
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var searchText = ""
	
	var filteredDecks: [Deck] {
		
		let decksToFilter: [Deck]
		
		if searchText.isEmpty {
			decksToFilter = decks
		} else {
			decksToFilter = decks.filter {
				$0.name.localizedCaseInsensitiveContains(searchText)
			}
		}
		return decksToFilter.sorted { ($0.lastOpenedAt ?? $0.createdAt) > ($1.lastOpenedAt ?? $1.createdAt) }
	}
	
	var body: some View {
		NavigationStack {
			List {
				Button {
					selectedDeck = nil
					dismiss()
				} label: {
					HStack {
						Text("Every Card")
							.foregroundStyle(Color.accent)
						if selectedDeck == nil {
							Spacer()
							Image(systemName: "checkmark")
						}
					}
				}
				ForEach(filteredDecks) { deck in
					Button {
						selectedDeck = deck
						dismiss()
					} label: {
						HStack {
							Text(deck.name)
								.foregroundStyle(Color(.label))
							if selectedDeck?.id == deck.id {
								Spacer()
								Image(systemName: "checkmark")
							}
						}
					}
				}
			}
			.navigationTitle("Select Deck")
			.searchable(text: $searchText, prompt: "Search a deck")
		}
	}
}

#Preview {
	@Previewable @State var selectedDeck: Deck? = nil
	
	let decks = [
		Deck(name: "Spanish", image: "deck"),
		Deck(name: "English", image: "deck"),
		Deck(name: "French", image: "deck"),
		Deck(name: "Portuguese", image: "deck"),
	]
	
	TimeTrialDeckSelectionView(selectedDeck: $selectedDeck, decks: decks)
}
