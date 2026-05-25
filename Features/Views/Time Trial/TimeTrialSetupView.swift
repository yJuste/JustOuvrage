//
//  TimeTrialSetupView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/23/26.
//

import SwiftUI
import SwiftData

// MARK: Can create a new enum for every variable in TrialView
// MARK: Case name missing for optionsOfOrder

struct TimeTrialSetupView: View {
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@Bindable private var preferences: Preferences = .unique
	@State private var argument: Argument?
	@State private var showTimeTrial: Bool = false
	@State private var showNoCards: Bool = false
	
	private let optionsOfTimer: [TimeInterval] = [1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, Constants.infinityYear]
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
	
	private var deckName: String {
		guard let id = preferences.trialDeck, let deck = decks.first(where: { $0.id == id }) else { return "Every Card" }
		return deck.name
	}
	
	var body: some View {
		NavigationStack {
			Form {
				Section {
					NavigationLink {
						TimeTrialDeckSelectionView(selectedDeck: selectedDeck, decks: decks)
					} label: {
						HStack {
							Text("Deck")
							Spacer()
							Text(deckName)
								.foregroundStyle(.secondary)
						}
					}
				} footer: {
					Text("Select a deck to study.")
				}
				Section {
					Picker(selection: $preferences.trialNumberOfCards) {
						ForEach(optionsOfNumberOfCards, id: \.self) { count in
							switch count {
							case 0: Text("All")
									.tag(count as Int)
							default: Text(count, format: .number)
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
					Picker(selection: $preferences.trialMode) {
						ForEach(optionsOfMode, id: \.self) { mode in
							switch mode {
							case .chill: Text("Chill")
									.tag(mode)
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
  
  Chill:
  - definitions may be shown.
  - ∞ swipe timer.
  - newest to oldest.
  
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
				if preferences.trialMode == .custom {
					Group {
						Section {
							Picker(selection: $preferences.trialTimeInterval) {
								ForEach(optionsOfTimer, id: \.self) { time in
									switch time {
									case Constants.infinityYear: Text("Infinity")
											.tag(time as TimeInterval)
									default: Text("\(time, format: .number.precision(.fractionLength(0...1))) sec")
											.tag(time as TimeInterval)
									}
								}
							} label: {
								Text("Timer")
							}
						} footer: {
							Text("Maximum time per card.")
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
									case .alphabeticalAscending:
										Text("A → Z Ascending")
											.tag(order)
									case .alphabeticalDescending:
										Text("Z → A Descending")
											.tag(order)
									}
								}
							} label: {
								Text("Order by")
							}
						} footer: {
							Text("Order in which cards are shown.")
						}
					}
					.transition(.opacity.combined(with: .move(edge: .top)))
				}
			}
			.animation(.spring(response: 0.35, dampingFraction: 0.9), value: preferences.trialMode)
			.toolbar { toolbar }
			.navigationDestination(isPresented: $showTimeTrial) {
				if let argument = argument {
					TimeTrialView(argument: argument)
						.navigationBarBackButtonHidden(true)
				}
			}
			.alert("No cards selected", isPresented: $showNoCards) {
				Button("OK", role: .cancel) { }
			} message: {
				Text("You can't start the Time Trial because there are no cards in the deck.")
			}
			.navigationTitle("Time Trial")
			.toolbarTitleDisplayMode(.inlineLarge)
			.scrollIndicators(.hidden)
		}
	}
}

/// Toolbar.
fileprivate extension TimeTrialSetupView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				let arg = Argument.make(deck: selectedDeck.wrappedValue, cards: cards, mode: preferences.trialMode, directions: [], timeInterval: preferences.trialTimeInterval, order: preferences.trialOrder, numberOfCards: preferences.trialNumberOfCards)
				guard !arg.cards.isEmpty else { return showNoCards.toggle() }
				argument = arg
				showTimeTrial.toggle()
			} label: {
				Text("Go!")
			}
			.buttonStyle(.borderedProminent)
		}
	}
}

#Preview {
	TimeTrialSetupView()
}
