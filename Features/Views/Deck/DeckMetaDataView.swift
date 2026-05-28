//
//  DeckMetaDataView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/24/26.
//

import SwiftUI

struct DeckMetaDataView: View {
	
	let deck: Deck
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					LeadingLabel(title: "Date") {
						Text(deck.createdAt, format: .dateTime.year().month().day().hour().minute())
					}
					LeadingLabel(title: "Number of Cards") {
						Text(deck.cards.count, format: .number)
					}
					LeadingLabel(title: "Name") {
						Text(deck.name)
					}
					let depiction = deck.depiction
					LeadingLabel(title: "Description") {
						Text(!depiction.isEmpty ? depiction : "No description")
					}
					LeadingLabel(title: "Author") {
						Text(deck.author)
					}
					LeadingLabel(title: "Language") {
						Text(deck.cards.isEmpty ? "No language" : Set(deck.cards.flatMap { [$0.frontLanguage, $0.backLanguage] }).sorted().map(\.language).joined(separator: " ⋅ ")
						)
						.font(.caption)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
				.padding()
			}
			.toolbar { toolbar }
			.navigationTitle("Metadata")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

/// Toolbar.
fileprivate extension DeckMetaDataView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				dismiss()
			} label: {
				Label("Close", systemImage: "xmark")
			}
			.tint(nil)
		}
	}
}

#Preview {
	
	let deck = Deck(name: "Hello", image: "deck")
	
	DeckMetaDataView(deck: deck)
}
