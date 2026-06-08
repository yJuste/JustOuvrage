//
//  CardMetaDataView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/26/26.
//

import SwiftUI

struct CardMetaDataView: View {
	
	let card: Card
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading) {
					LeadingLabel(title: "Date") {
						Text(card.createdAt, format: .dateTime.year().month().day().hour().minute())
					}
					LeadingLabel(title: "Front") {
						Text(card.frontEntry)
					}
					LeadingLabel(title: "Back") {
						Text(card.backEntry)
					}
					LeadingLabel(title: "Language") {
						VStack(alignment: .trailing) {
							Text(card.frontLanguage.language)
							Text(card.backLanguage.language)
						}
						.font(.caption)
					}
					.padding(.vertical, 2)
					LeadingLabel(title: "In Decks") {
						Text(card.decks.isEmpty ? "Not in any deck" : card.decks.map { $0.name }.sorted().joined(separator: " ⋅ "))
							.font(.caption)
					}
					LeadingLabel(title: "Recording") {
						HStack(spacing: 2) {
							let count = [card.frontRecording, card.backRecording].compactMap { $0 }.count
							if count == 0 {
								Text("(No recordings)")
							} else {
								ForEach(0..<count, id: \.self) { _ in
									Image(systemName: "circle.fill")
								}
								Text(count == 2 ? "(Both)" : "(one)")
									.padding(.leading, 5)
							}
						}
						.font(.caption)
					}
					LeadingLabel(title: "Leitner Score") {
						Text(card.leitnerScore, format: .number)
					}
					LeadingLabel(title: "Leitner Next") {
						if let nextDate = card.nextLeitnerAt {
							Text(nextDate, format: .dateTime.year().month().day().hour().minute())
						} else {
							Text("No date")
						}
					}
					LeadingLabel(title: "Author") {
						Text(card.author)
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
fileprivate extension CardMetaDataView {
	
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
	
	let card = Card(frontEntry: "Je suis la", backEntry: "I am here", frontLanguage: .fr_FR, backLanguage: .en_US, author: "yJuste")
	card.frontRecording = nil
	card.backRecording = nil
	
	return CardMetaDataView(card: card)
}
