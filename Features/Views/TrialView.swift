//
//  TrialView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/7/26.
//

import SwiftUI
import SwiftData

struct TrialView: View {
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@Query private var decks: [Deck]
	
	@State private var selectedTime: Int = 0
	@State private var optionsOfTimer: [String] = ["1 sec", "2 sec", "3 sec", "4 sec", "5 sec"]
	@State private var selectedDeck: Deck? = nil
	@State private var selectedNumberOfCards: Int = 0
	@State private var optionsOfNumberOfCards: [String] = ["All", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100", "110", "120", "130", "140", "150", "160", "170", "180", "190", "200"]
	@State private var selectedMode: Int = 0
	@State private var optionsOfMode: [String] = ["Standard", "Death"]
	
	@State private var showTimeTrial: Bool = false
	
	var filteredCards: [Card] {
		if let deck = selectedDeck {
			return cards.filter { $0.decks.contains(deck) }
		} else {
			return cards
		}
	}
	
	var body: some View {
		NavigationStack {
			Form {
				Section {
					Picker(selection: $selectedTime) {
						ForEach(optionsOfTimer.indices, id: \.self) {
							Text(self.optionsOfTimer[$0])
						}
					} label: {
						Text("Timer")
					}
				} footer: {
					Text("Set the maximum time to swipe for each cards.")
				}
				Section {
					Picker(selection: $selectedDeck) {
						Text("Every Card")
							.tag(Optional<Deck>.none)
						ForEach(decks) { deck in
							Text(deck.name)
								.tag(Optional(deck))
						}
					} label: {
						Text("Deck")
					}
					.pickerStyle(.navigationLink)
				} header: {
					Text("Choose the deck")
				} footer: {
					Text("Choose the deck you are going to work on.")
				}
				Section {
					Picker(selection: $selectedNumberOfCards) {
						ForEach(optionsOfNumberOfCards.indices, id: \.self) {
							Text(self.optionsOfNumberOfCards[$0])
						}
					} label: {
						Text("Cards")
					}
				} header: {
					Text("How many cards")
				}
				Section {
					Picker(selection: $selectedMode) {
						ForEach(optionsOfMode.indices, id: \.self) {
							Text(self.optionsOfMode[$0])
						}
					} label: {
						Text("Mode")
					}
				} header: {
					Text("Choose the difficulty")
				}
			}
			.toolbar { toolbar }
			.navigationDestination(isPresented: $showTimeTrial) {
				TimeTrialView(cards: filteredCards)
			}
		}
	}
}

/// Toolbar.
fileprivate extension TrialView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				dismiss()
			} label: {
				Label("Close", systemImage: "xmark")
			}
		}
		ToolbarItem(placement: .principal) {
			Text("Time Trial Mode")
				.font(.title3)
				.fontWeight(.semibold)
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				showTimeTrial.toggle()
			} label: {
				Text("Go!")
			}
			.buttonStyle(.borderedProminent)
		}
	}
}

#Preview {
	TrialView()
}
