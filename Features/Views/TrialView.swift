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
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@Bindable private var preferences: Preferences = Preferences.unique
	@State private var showTimeTrial: Bool = false
	
	private let optionsOfTimer: [TimeInterval] = [1.0, 2.0, 3.0, 4.0, 5.0]
	private let optionsOfNumberOfCards: [Int] = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200]
	private let optionsOfMode: [Int] = [0, 1]
	
	private var filteredCards: [Card] {
		if let deck = selectedDeck.wrappedValue {
			return cards.filter { $0.decks.contains(deck) }
		} else {
			return cards
		}
	}
	
	private var selectedDeck: Binding<Deck?> {
		Binding {
			guard let id = preferences.trialDeck else { return nil }
			return decks.first(where: { $0.id == id })
		} set: { newDeck in
			preferences.trialDeck = newDeck?.id
		}
	}
	
	var body: some View {
		NavigationStack {
			Form {
				Section {
					Picker(selection: $preferences.trialTimeInterval) {
						ForEach(optionsOfTimer, id: \.self) { time in
							Text("\(Int(time)) sec")
								.tag(time)
						}
					} label: {
						Text("Timer")
					}
				} footer: {
					Text("Set the maximum time to swipe for each cards.")
				}
				Section {
					Picker(selection: selectedDeck) {
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
					Picker(selection: $preferences.trialNumberOfCards) {
						ForEach(optionsOfNumberOfCards, id: \.self) { count in
							Text(count == 0 ? "All" : "\(count)")
								.tag(count as Int)
						}
					} label: {
						Text("Cards")
					}
				} header: {
					Text("How many cards")
				}
				Section {
					Picker(selection: $preferences.trialMode) {
						ForEach(optionsOfMode, id: \.self) { mode in
							Text(mode == 0 ? "Standard" : "Death")
								.tag(mode)
						}
					} label: {
						Text("Mode")
					}
				} header: {
					Text("Choose the difficulty")
				}
			}
			.navigationDestination(isPresented: $showTimeTrial) {
				TimeTrialView(
					cards: filteredCards,
					timeInterval: preferences.trialTimeInterval,
					deck: selectedDeck.wrappedValue,
					numberOfCards: preferences.trialNumberOfCards,
					mode: preferences.trialMode
				)
				.navigationBarBackButtonHidden(true)
			}
			.toolbar { toolbar }
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
				.font(.headline)
				.foregroundStyle(.secondary)
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
