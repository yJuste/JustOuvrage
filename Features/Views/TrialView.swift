//
//  TrialView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/7/26.
//

import SwiftUI
import SwiftData

// MARK: Can create a new enum for every variable in TrialView
// MARK: Case name missing for optionsOfOrder

struct TrialView: View {
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@Bindable private var preferences: Preferences = Preferences.unique
	@State private var argument: Argument?
	@State private var showTimeTrial: Bool = false
	
	private let optionsOfTimer: [TimeInterval] = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]
	private let optionsOfNumberOfCards: [Int] = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200]
	private let optionsOfOrder: [SortTrial] = SortTrial.allCases
	private let optionsOfMode: [Mode] = Mode.allCases
	
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
							Text("\(time, format: .number.precision(.fractionLength(0...1))) sec")
								.tag(time)
						}
					} label: {
						Text("Timer")
					}
				} footer: {
					Text("Maximum time per card.")
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
				} footer: {
					Text("Select a deck to study.")
				}
				Section {
					Picker(selection: $preferences.trialNumberOfCards) {
						ForEach(optionsOfNumberOfCards, id: \.self) { count in
							switch count {
							case 0: Text("All")
									.tag(count as Int)
							default: Text("\(count)")
									.tag(count as Int)
							}
						}
					} label: {
						Text("Cards")
					}
				} footer: {
					Text("How many cards to include in this session.")
				}
				Section {
					Picker(selection: $preferences.trialOrder) {
						ForEach(optionsOfOrder, id: \.self) { order in
							switch order {
							case .random: Text("Random (default)")
									.tag(order)
							case .newestToOldest: Text("Newest to Oldest")
									.tag(order)
							case .oldestToNewest: Text("Oldest to Newest")
									.tag(order)
							default: Text("[Unknown order]")
									.tag(order)
							}
						}
					} label: {
						Text("Order by")
					}
				} footer: {
					Text("Order in which cards are shown.")
				}
				Section {
					Picker(selection: $preferences.trialMode) {
						ForEach(optionsOfMode, id: \.self) { mode in
							switch mode {
							case .standard: Text("Standard")
									.tag(mode)
							case .death: Text("Death")
									.tag(mode)
							case .custom: Text("Custom")
									.tag(mode)
							}
						}
					} label: {
						Text("Mode")
					}
				} header: {
					Text("Difficulty")
				} footer: {
					Text("""
  The selected mode applies to the session.
  
  Standard:
  - definitions may be shown.
  - 4s swipe timer.
  - random order.
  
  Death:
  - no definitions.
  - 1.5s swipe timer.
  - random order.
  
  Custom = fully configurable settings.
  """)
				}
			}
			.navigationDestination(isPresented: $showTimeTrial) {
				if let argument = argument {
					TimeTrialView(
						cards: argument.cards,
						timeInterval: argument.timeInterval
					)
					.navigationBarBackButtonHidden(true)
				}
			}
			.toolbar { toolbar }
		}
	}
}

// Default deck is Every card.
// Default order is Newest to Oldest.
// Default limit is All.
fileprivate extension TrialView {
	
	private struct Argument {
		
		let cards: [Card]
		let timeInterval: TimeInterval
	}
	
	private func argument(from cards: [Card]) -> Argument {
		
		var res = cards
		
		if let deck = selectedDeck.wrappedValue {
			res = res.filter { $0.decks.contains(deck) }
		}
		switch preferences.trialOrder {
		case .random: res.shuffle()
		case .newestToOldest: break
		case .oldestToNewest: res = res.sorted { $0.createdAt < $1.createdAt }
		default: break
		}
		let limit = preferences.trialNumberOfCards
		if limit > 0 {
			res = Array(res.prefix(limit))
		}
		let mode = preferences.trialMode
		var interval = preferences.trialTimeInterval
		switch mode {
		case .standard: res.shuffle(); interval = 4.0
		case .death: res.shuffle(); interval = 1.5
		case .custom: break
		}
		return Argument(cards: res, timeInterval: interval)
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
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				argument = argument(from: cards)
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
