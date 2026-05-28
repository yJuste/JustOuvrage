//
//  DeckSelectionView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/28/26.
//

import SwiftUI
import SwiftData

struct DeckSelectionView: View {
	
	@Binding var selectedDeck: Deck?
	
	@Query(sort: [SortDescriptor(\Deck.lastOpenedAt, order: .reverse), SortDescriptor(\Deck.createdAt, order: .reverse)]) private var decks: [Deck]
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var searchText = ""
	
	var filteredDecks: [Deck] {
		decks.filter { searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText) }
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
							.foregroundStyle(.primary)
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
	
	DeckSelectionView(selectedDeck: $selectedDeck)
}
