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
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@Bindable private var preferences: Preferences = .unique
	@State private var argument: Argument
	@State private var timeTrial: TimeTrial?
	@State private var currentIndex: Int = 0
	@State private var hasTimerReachedZero: Bool = false
	@State private var hasTimerPaused: Bool = false
	@State private var dragOffset: CGSize = .zero
	@State private var rotation: Double = 0
	@State private var directions: [SwipeDirection] = []
	@State private var showPause: Bool = false
	@State private var isSwiping: Bool = false
	@State private var isCardTapped: Bool = false
	@State private var remainingTime: TimeInterval
	@State private var colors: [Color]?
	@State private var showGradientBackground: Bool = Preferences.unique.gradientBackground
	@State private var showAnimationBackground: Bool = Preferences.unique.animationBackground
	
	private var currentCard: Card? {
		guard currentIndex < argument.cards.count else { return nil }
		return argument.cards[currentIndex]
	}
	
	private let timer = Timer.publish(every: Preferences.unique.trialRefreshTimer, on: .main, in: .common).autoconnect()
	
	private var selectedDeck: Deck? {
		decks.first { $0.id == argument.deck?.id }
	}
	
	private let rectangle: RoundedRectangle = RoundedRectangle(cornerRadius: 35, style: .continuous)
	
	init(argument: Argument) {
		_argument = State(initialValue: argument)
		_remainingTime = State(initialValue: argument.timeInterval)
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				if showGradientBackground {
					if let colors {
						AmazingBackground(colors: colors, active: showAnimationBackground ? true : false)
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
							.disabled(isSwiping)
						}
					}
					.foregroundStyle(showGradientBackground && colors?.last != nil ? .white : .primary)
					.frame(maxWidth: .infinity, maxHeight: .infinity)
				}
			}
			.onChange(of: hasTimerReachedZero) { _, reached in
				guard reached else { return }
				swipe(.left)
			}
			.onReceive(timer) { _ in
				guard !hasTimerPaused else { return }
				guard currentCard != nil else { return }
				if remainingTime > 0 {
					remainingTime = max(remainingTime - preferences.trialRefreshTimer, 0)
				} else {
					hasTimerReachedZero = true
				}
			}
			.onAppear {
				loadImageForBackground()
			}
			.navigationDestination(item: $timeTrial) { trial in
				TimeTrialResultView(timeTrial: trial)
			}
			.toolbar { toolbar }
			.toolbar(.hidden, for: .tabBar)
			.alert("Quit Time Trial ?", isPresented: $showPause) {
				Button("Continue", role: .cancel) {
					hasTimerPaused = false
				}
				Button("Quit", role: .destructive) {
					dismiss()
				}
			} message: {
				Text("The timer is currently paused.")
			}
		}
	}
	
	private func flashcard(card: Card, height: CGFloat, width: CGFloat, isPortrait: Bool) -> some View {
		
		ZStack {
			rectangle
				.fill(.clear)
				.contentShape(rectangle)
			rectangle
				.stroke(.primary.opacity(0.1), lineWidth: 2)
			VStack(spacing: 24) {
				Spacer()
				Text(card.frontEntry)
					.font(.system(size: width * (isPortrait ? 0.06 : 0.04), weight: .semibold))
					.foregroundStyle(.primary)
				if isCardTapped && argument.mode != .death {
					Text(card.backEntry)
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
				.fill(LinearGradient(colors: [.red.opacity(Double(-dragOffset.width / 200)), .red.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
				.opacity(dragOffset.width < 0 ? 1 : 0)
			rectangle
				.fill(LinearGradient(colors: [.green.opacity(Double(dragOffset.width / 200)), .green.opacity(0.0)], startPoint: .trailing, endPoint: .leading))
				.opacity(dragOffset.width > 0 ? 1 : 0)
			TimerView(size: (isPortrait ? 70 : 20), duration: argument.timeInterval, remainingTime: remainingTime, color: showGradientBackground ? .white : UIColor.label)
				.offset(y: height * 0.25)
		}
		.frame(width: width * (isPortrait ? 0.9 : 0.9), height: height * (isPortrait ? 0.85 : 1.0))
		.offset(x: dragOffset.width, y: dragOffset.height)
		.rotationEffect(.degrees(rotation))
		.gesture(
			isSwiping ? nil :
				DragGesture()
				.onChanged { value in
					dragOffset = value.translation
					rotation = value.translation.width / 30
				}
				.onEnded { value in
					let horizontal = value.translation.width
					if horizontal > 50 {
						swipe(.right)
					} else if horizontal < -50 {
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

/// SwipeDirection
fileprivate extension TimeTrialView {
	
	private func swipe(_ direction: SwipeDirection) {
		
		guard !isSwiping else { return }
		isSwiping = true
		directions.append(direction)
		hasTimerPaused = true
		
		withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
			dragOffset.width = direction == .right ? 900 : -900
			rotation = direction == .right ? 14 : -14
		}
		
		Task { @MainActor in
			self.currentIndex += 1
			if self.currentIndex >= argument.cards.count {
				argument.directions = directions
				let result = TimeTrial(argument: argument, with: calculateSuccesRate(argument.directions))
				modelContext.insert(result)
				timeTrial = result
			}
			self.isCardTapped = false
			self.dragOffset = .zero
			self.rotation = 0
			self.hasTimerReachedZero = false
			self.hasTimerPaused = false
			self.remainingTime = argument.timeInterval
			self.isSwiping = false
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
}

/// Background for Gradient & Deck.
fileprivate extension TimeTrialView {
	
	private func backgroundDeck(geo: GeometryProxy) -> some View {
		RoundedRectangle(cornerRadius: 35, style: .continuous)
			.fill(.primary.opacity(0.05))
			.frame(
				width: geo.size.width * 0.90,
				height: geo.size.height * 0.58
			)
	}
	
	private func calculateSuccesRate(_ directions: [SwipeDirection]) -> Double {
		guard !directions.isEmpty else { return 0 }
		return Double(directions.filter { $0 == .right }.count) / Double(directions.count)
	}
}

/// Toolbar.
fileprivate extension TimeTrialView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				hasTimerPaused = true
				showPause.toggle()
			} label: {
				Label("Close", systemImage: "xmark")
			}
		}
		ToolbarItem(placement: .principal) {
			Text(selectedDeck?.name ?? "Every Card")
				.font(.headline)
				.foregroundStyle(showGradientBackground && colors?.last != nil ? .white : .primary)
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				//
			} label: {
				Text("\(min(currentIndex + 1, argument.cards.count))/\(argument.cards.count)")
			}
		}
	}
}

#Preview {
	
	let cards: [Card] = [Card(frontEntry: "FrontEntry", backEntry: "BackEntry", frontLanguage: .fr_CA, backLanguage: .en_GB)]
	
	let deck = Deck(name: "Title deck", image: "deck")
	
	let argument = Argument.make(deck: deck, cards: cards, mode: .chill, directions: [.left], timeInterval: 4.0, order: .alphabeticalAscending, numberOfCards: 30)
	
	TimeTrialView(argument: argument)
}
