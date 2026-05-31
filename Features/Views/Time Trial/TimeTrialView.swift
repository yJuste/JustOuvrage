//
//  TimeTrialView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/7/26.
//

import SwiftUI
import SwiftData
import Combine

struct TimeTrialView: View {
	
	@Environment(FileImageStorage.self) private var storage
	@Environment(Recording.self) private var recording
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@Bindable private var preferences: Preferences = .unique
	@State private var argument: Argument
	@State private var timeTrial: TimeTrial?
	@State private var currentIndex: Int = 0
	@State private var hasTimerReachedZero: Bool = false
	@State private var dragOffset: CGSize = .zero
	@State private var rotation: Double = 0
	@State private var directions: [SwipeDirection] = []
	@State private var showPause: Bool = false
	@State private var isCardTapped: Bool = false
	@State private var remainingTime: TimeInterval
	@State private var colors: [Color]?
	@State private var showGradientBackground: Bool = Preferences.unique.gradientBackground
	@State private var showAnimationBackground: Bool = Preferences.unique.animationBackground
	@State private var showLeitner: Bool
	
	private var currentCard: Card? {
		let cards = argument.cards
		guard currentIndex < cards.count else { return nil }
		return cards[currentIndex]
	}
	
	private let timer = Timer.publish(every: Preferences.unique.trialRefreshTimer, on: .main, in: .common).autoconnect()
	
	private var selectedDeck: Deck? {
		decks.first { $0.id == argument.deck?.id }
	}
	
	private let rectangle: RoundedRectangle = RoundedRectangle(cornerRadius: 35, style: .continuous)
	
	init(argument: Argument) {
		_argument = State(initialValue: argument)
		_remainingTime = State(initialValue: argument.timeInterval)
		_showLeitner = State(initialValue: false)
	}
	
	init(cards: [Card], leitner: Bool = false) {
		if leitner {
			let activeArgument = Argument(cards: cards)
			_argument = State(initialValue: activeArgument)
			_remainingTime = State(initialValue: activeArgument.timeInterval)
			_showLeitner = State(initialValue: true)
		} else {
			let activeArgument = Argument(cards: cards)
			_argument = State(initialValue: activeArgument)
			_remainingTime = State(initialValue: activeArgument.timeInterval)
			_showLeitner = State(initialValue: false)
		}
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				if showGradientBackground {
					if let colors {
						AmazingBackground(colors: colors, active: showAnimationBackground ? true : false)
							.opacity(colorScheme == .dark ? 0.5 : 1.0)
							.ignoresSafeArea()
					}
				}
				GeometryReader { geo in
					
					let height = geo.size.height
					let width = geo.size.width
					let isPortrait: Bool = height > width
					
					VStack(spacing: isPortrait ? height * 0.05 : height * 1.0) {
						if let card = currentCard {
							ZStack {
								flashcard(card: card, height: height, width: width, isPortrait: isPortrait)
									.background(
										rectangle
											.fill(.primary.opacity(0.05))
											.frame(width: width * (isPortrait ? 0.83 : 0.86), height: height * (isPortrait ? 0.8 : 0.89))
									)
							}
							HStack(spacing: width * 0.15) {
								Button {
									swipe(.left)
								} label: {
									Image(systemName: "xmark")
										.foregroundStyle(.red)
										.frame(width: 70, height: 70)
										.glassEffect(.regular.interactive())
								}
								Button {
									swipe(.right)
								} label: {
									Image(systemName: "checkmark")
										.foregroundStyle(.green)
										.frame(width: 70, height: 70)
										.glassEffect(.regular.interactive())
								}
							}
							.font(.system(size: 35, weight: .semibold))
						}
					}
					.foregroundStyle(showGradientBackground && colors?.last != nil ? .white : .primary)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
				}
			}
			.onReceive(timer) { _ in
				guard !showPause else { return }
				guard currentCard != nil else { return }
				if remainingTime > 0 {
					remainingTime = max(remainingTime - preferences.trialRefreshTimer, 0)
				} else {
					hasTimerReachedZero = true
				}
			}
			.onChange(of: hasTimerReachedZero) { _, newValue in
				guard newValue else { return }
				swipe(.left)
			}
			.onChange(of: currentIndex) {
				playCurrentCardAudio()
			}
			.onAppear {
				loadImageForBackground()
			}
			.onAppear {
				loadImageForBackground()
				playCurrentCardAudio()
			}
			.navigationDestination(item: $timeTrial) { trial in
				TimeTrialResultView(timeTrial: trial)
			}
			.toolbar { toolbar }
			.toolbar(.hidden, for: .tabBar)
			.alert("Quit Time Trial ?", isPresented: $showPause) {
				Button("Continue", role: .cancel) { }
				Button("Quit", role: .destructive) {
					dismiss()
				}
			} message: {
				Text("The timer is currently paused.")
			}
		}
	}
	
	private func flashcard(card: Card, height: CGFloat, width: CGFloat, isPortrait: Bool) -> some View {
		let dragheight = dragOffset.height
		let dragwidth = dragOffset.width
		let entry = sideEntries(for: card)
		return ZStack {
			rectangle
				.fill(.clear)
				.contentShape(rectangle)
			rectangle
				.stroke(.primary.opacity(0.1), lineWidth: 2)
			VStack(spacing: 24) {
				Spacer()
				Text(entry.front)
					.font(.system(size: width * (isPortrait ? 0.06 : 0.04), weight: .semibold))
					.foregroundStyle(.primary)
				if isCardTapped && argument.mode != .death {
					Text(entry.back)
						.font(.system(size: width * (isPortrait ? 0.05 : 0.03), weight: .semibold))
						.foregroundStyle(.secondary)
				}
				if !isPortrait { Spacer() }
				Spacer()
			}
			.multilineTextAlignment(.center)
			.padding(.horizontal, 15)
			.animation(.easeInOut(duration: 0.1), value: isCardTapped)
			rectangle
				.fill(LinearGradient(colors: [.red.opacity(Double(-dragwidth / 200)), .red.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
				.opacity(dragwidth < 0 ? 1 : 0)
			rectangle
				.fill(LinearGradient(colors: [.green.opacity(Double(dragwidth / 200)), .green.opacity(0.0)], startPoint: .trailing, endPoint: .leading))
				.opacity(dragwidth > 0 ? 1 : 0)
			TimerView(size: (isPortrait ? 70 : 20), duration: argument.timeInterval, remainingTime: remainingTime, color: (showGradientBackground && colors?.last != nil) ? .white : (colorScheme == .light ? .black : .white))
				.offset(y: height * 0.25)
		}
		.frame(width: width * (isPortrait ? 0.9 : 0.9), height: height * (isPortrait ? 0.85 : 1.0))
		.offset(x: dragwidth, y: dragheight)
		.rotationEffect(.degrees(rotation))
		.gesture(
			DragGesture()
				.onChanged { value in
					let translation = value.translation
					dragOffset = translation
					rotation = translation.width / 30
				}
				.onEnded { value in
					let horizontal = value.translation.width
					let swipeTrigger = preferences.trialSwipeThreshold
					if horizontal > swipeTrigger {
						swipe(.right)
					} else if horizontal < -swipeTrigger {
						swipe(.left)
					} else {
						withAnimation(.spring(response: 0.4)) {
							dragOffset = .zero
							rotation = 0
						}
					}
				}
		)
		.onTapGesture {
			isCardTapped.toggle()
		}
	}
}

/// Methods of TimeTrialView.
fileprivate extension TimeTrialView {
	
	private func swipe(_ direction: SwipeDirection) {
		
		withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
			dragOffset.width = direction == .right ? 900 : -900
			rotation = direction == .right ? 14 : -14
		}
		
		directions.append(direction)
		currentIndex += 1
		isCardTapped = false
		dragOffset = .zero
		rotation = 0
		hasTimerReachedZero = false
		remainingTime = argument.timeInterval
		
		let cards = argument.cards
		if currentIndex >= cards.count {
			if showLeitner {
				for (index, card) in cards.enumerated() {
					if directions[index] == .right {
						Leitner.update(for: card, score: card.leitnerScore + 1)
					} else {
						Leitner.update(for: card, score: 1)
					}
				}
			}
			argument.directions = directions
			let result = TimeTrial(argument: argument, with: calculateSuccesRate(directions))
			modelContext.insert(result)
			timeTrial = result
		}
	}
	
	private func loadImageForBackground() {
		if let deckImage = argument.deck?.image {
			if let uiImage = try? storage.load(image: deckImage, size: 512) {
				if showGradientBackground {
					colors = Theme.gradientColors(from: uiImage)
				}
			} else {
				colors = nil
			}
		}
	}
	
	private func calculateSuccesRate(_ directions: [SwipeDirection]) -> Double {
		guard !directions.isEmpty else { return 0 }
		return Double(directions.filter { $0 == .right }.count) / Double(directions.count)
	}
	
	private func sideReversed(for card: Card) -> Bool {
		argument.reversedCards[card.id] ?? false
	}
	
	private func sideEntries(for card: Card) -> (front: String, back: String) {
		
		if sideReversed(for: card) {
			return (front: card.backEntry, back: card.frontEntry)
		}
		return (front: card.frontEntry, back: card.backEntry)
	}
	
	private func playCurrentCardAudio() {
		
		guard let card = currentCard else { return }
		let filename: String?
		
		if sideReversed(for: card) {
			filename = card.backRecording
		} else {
			filename = card.frontRecording
		}
		recording.play(filename)
	}
}

/// Toolbar.
fileprivate extension TimeTrialView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				showPause.toggle()
			} label: {
				Label("Close", systemImage: "xmark")
			}
			.tint(nil)
		}
		ToolbarItem(placement: .principal) {
			Text(selectedDeck?.name ?? "Every Card")
				.font(.headline)
				.foregroundStyle(showGradientBackground && colors?.last != nil ? .white : .primary)
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				// Nothing
			} label: {
				let count = argument.cards.count
				Text("\(min(currentIndex + 1, count))/\(count)")
			}
			.foregroundStyle(.primary)
		}
	}
}

#Preview {
	
	let cards: [Card] = [Card(frontEntry: "FrontEntry", backEntry: "BackEntry", frontLanguage: .fr_CA, backLanguage: .en_GB)]
	
	let deck = Deck(name: "Title deck", image: "deck")
	
	let argument = Argument.make(deck: deck, cards: cards, side: .front, mode: .chill, directions: [.left], timeInterval: 4.0, order: .alphabeticalAscending, numberOfCards: 30)
	
	TimeTrialView(argument: argument)
}
