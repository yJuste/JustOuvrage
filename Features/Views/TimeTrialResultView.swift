//
//  TimeTrialResultView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/8/26.
//

import SwiftUI
import SwiftData

struct TimeTrialResultView: View {
	
	let argument: Argument
	let results: [SwipeDirection]
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@State private var timeTrial: TimeTrial?
	@State private var showSave: Bool = false
	
	private var selectedDeck: Deck? {
		decks.first { $0.id == argument.deck?.id }
	}
	
	var body: some View {
		
		NavigationStack {
			List {
				Section {
					ForEach(argument.cards.indices, id: \.self) { index in
						let card = argument.cards[index]
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
				Section { /// ``metadata``
					VStack(alignment: .leading) {
						Text("\(timeTrial?.createdAt ?? .now, format: .dateTime.year().month().day())")
						Text("\(timeTrial?.deck?.name ?? "Every Card")")
						if let mode = timeTrial?.mode {
							Text(mode.mode)
						}
						Text("\((timeTrial?.success ?? 0), format: .percent.precision(.fractionLength(0...1))) success")
					}
					.foregroundStyle(.secondary)
					.frame(maxWidth: .infinity, alignment: .leading)
				}
				.listRowSeparator(.hidden)
			}
			.onAppear {
				let newTimeTrial = TimeTrial(argument: argument, with: calculateSuccesRate(results))
				modelContext.insert(newTimeTrial)
				timeTrial = newTimeTrial
			}
			.toolbar { toolbar }
			.listStyle(.plain)
		}
		.navigationBarBackButtonHidden(true)
	}
}

fileprivate extension TimeTrialResultView {
	
	private func calculateSuccesRate(_ results: [SwipeDirection]) -> Double {
		guard !results.isEmpty else { return 0 }
		return Double(results.filter { $0 == .right }.count) / Double(results.count)
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
	
	let cards: [Card] = [Card(frontEntry: "FrontEntry", backEntry: "BackEntry", frontLanguage: .fr_CA, backLanguage: .en_GB)]
	
	let deck = Deck(name: "Title deck", image: "deck")
	
	let argument = Trial.make(cards: cards, deck: deck, mode: .chill, order: .alphabeticalAscending, numberOfCards: 30, interval: 5.0)
	
	let res: [SwipeDirection] = [.left, .right, .right]
	
	TimeTrialResultView(argument: argument, results: res)
}
