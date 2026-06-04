//
//  TimeTrialResultView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/8/26.
//

import SwiftUI
import SwiftData

struct TimeTrialResultView: View {
	
	let timeTrial: TimeTrial
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var showSave: Bool = false
	
	var body: some View {
		
		NavigationStack {
			List {
				Section {
					ForEach(timeTrial.cards.indices, id: \.self) { index in
						let card = timeTrial.cards[index]
						let result = timeTrial.directions.indices.contains(index) ? timeTrial.directions[index] : nil
						ZStack {
							HStack {
								VStack(alignment: .leading, spacing: 5) {
									Text(card.frontEntry)
									Text(card.backEntry)
										.foregroundStyle(.secondary)
								}
								.font(.subheadline)
								Spacer()
								if result == .left {
									Image(systemName: "xmark.diamond.fill")
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
				} /// ``list card``
				.listRowSeparator(.hidden)
				.listRowInsets(EdgeInsets(top: 6, leading: 15, bottom: 6, trailing: 15))
				Section {
					VStack(alignment: .leading) {
						Text(timeTrial.createdAt, format: .dateTime.year().month().day())
						Text(timeTrial.deck?.name ?? "Every Card")
						Text(timeTrial.mode.mode)
						Text("\((timeTrial.success), format: .percent.precision(.fractionLength(0...1))) success")
					}
					.foregroundStyle(.secondary)
					.frame(maxWidth: .infinity, alignment: .leading)
				} /// ``metadata``
				.listRowSeparator(.hidden)
			}
			.toolbar { toolbar }
			.listStyle(.plain)
			.navigationBarBackButtonHidden(true)
		}
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
			.tint(nil)
		}
		ToolbarItem(placement: .principal) {
			VStack {
				Text("Results")
					.font(.headline)
				Text("for \"\(timeTrial.deck?.name ?? "Every Card")\"")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
	}
}

#Preview {
	
	let cards: [Card] = [Card(frontEntry: "FrontEntry", backEntry: "BackEntry", frontLanguage: .fr_CA, backLanguage: .en_GB, author: "yJuste")]
	let deck = Deck(name: "Title deck", image: "deck", author: "yJuste")
	let res: [SwipeDirection] = [.left, .right, .right]
	let argument = Argument.make(deck: deck, cards: cards, side: .front, mode: .chill, directions: res, timeInterval: 4.0, order: .alphabeticalAscending, numberOfCards: 30)
	
	TimeTrialResultView(timeTrial: TimeTrial(argument: argument, with: 34.8))
}
