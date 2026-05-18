//
//  TimeTrialResultView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/8/26.
//

import SwiftUI
import SwiftData

struct TimeTrialResultView: View {
	
	let cards: [Card]
	let results: [SwipeDirection]
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@Bindable private var preferences: Preferences = Preferences.unique
	@State private var showSave: Bool = false
	
	private var selectedDeck: Deck? {
		decks.first { $0.id == preferences.trialDeck }
	}
	
	var body: some View {
		
		NavigationStack {
			List {
				Section { // list every card
					ForEach(cards.indices, id: \.self) { index in
						let card = cards[index]
						let result = results.indices.contains(index) ? results[index] : nil
						ZStack {
							HStack {
								VStack(alignment: .leading, spacing: 5) {
									Text(card.frontEntry)
										.font(.subheadline)
									Text(card.backEntry)
										.font(.subheadline)
										.foregroundStyle(.secondary)
								}
								Spacer()
								if result == .left {
									Image(systemName: "xmark.rectangle.portrait.fill")
										.foregroundStyle(.red)
								} else if result == .right {
									Image(systemName: "checkmark.rectangle.portrait.fill")
										.foregroundStyle(.green)
								}
							}
							.padding()
						}
						.overlay {
							if result == .right {
								RoundedRectangle(cornerRadius: 15)
									.fill(LinearGradient(colors: [.green.opacity(0.6), .green.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
							}
							else if result == .left {
								RoundedRectangle(cornerRadius: 15)
									.fill(LinearGradient(colors: [.red.opacity(0.6), .red.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
							}
						}
					}
				}
				.listRowSeparator(.hidden)
				.listRowInsets(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
				Section { /// ``metadata``
					VStack(alignment: .leading) {
						Text("[created at]")
						Text("Deck chosen")
						Text("mode")
					}
					.foregroundStyle(.secondary)
					.frame(maxWidth: .infinity, alignment: .leading)
				}
				.listRowSeparator(.hidden)
			}
			.listStyle(.plain)
			.toolbar { toolbar }
		}
		.navigationBarBackButtonHidden(true)
	}
}

/// Toolbar.
fileprivate extension TimeTrialResultView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				dismiss()
			} label: {
				Label("Close", systemImage: "xmark")
			}
		}
		ToolbarItem(placement: .principal) {
			VStack {
				Text("Results")
					.font(.headline)
				Text("for \"\(selectedDeck?.name ?? "Every Card")\"")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
	}
}

#Preview {
	
	let cards: [Card] = (1...3).map { index in
		Card(
			frontEntry: "Sample Front \(index)",
			backEntry: "Exemple Dos \(index)",
			frontLanguage: .en_US,
			backLanguage: .fr_CA
		)
	}
	let res: [SwipeDirection] = [.left, .right, .right]
	
	TimeTrialResultView(cards: cards, results: res)
}
