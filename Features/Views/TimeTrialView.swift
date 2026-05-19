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
	
	let cards: [Card]
	let timeInterval: TimeInterval
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
	
	@Bindable private var preferences: Preferences = Preferences.unique
	@State private var currentIndex: Int = 0
	@State private var hasTimerReachedZero: Bool = false
	@State private var hasTimerPaused: Bool = false
	@State private var dragOffset: CGSize = .zero
	@State private var rotation: Double = 0
	@State private var swipeResults: [SwipeDirection] = []
	@State private var showPause: Bool = false
	@State private var isSwiping: Bool = false
	@State private var isCardTapped: Bool = false
	@State private var remainingTime: TimeInterval
	@State private var showTimeTrialResult: Bool = false
	
	private var currentCard: Card? {
		guard currentIndex < cards.count else { return nil }
		return cards[currentIndex]
	}
	
	private let timer = Timer.publish(every: Preferences.unique.trialRefreshTimer, on: .main, in: .common).autoconnect()
	
	private var selectedDeck: Deck? {
		decks.first { $0.id == preferences.trialDeck }
	}
	
	init(cards: [Card], timeInterval: TimeInterval) {
		self.cards = cards
		self.timeInterval = timeInterval
		_remainingTime = State(initialValue: timeInterval)
	}
	
	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				let isPortrait: Bool = geo.size.height > geo.size.width
				ZStack {
					backgroundGradient
					VStack(spacing: isPortrait ? geo.size.height * 0.05 : geo.size.height * 1.0) {
						if let card = currentCard {
							ZStack {
								flashcard(card: card, geo: geo, isPortrait: isPortrait)
									.background(
										RoundedRectangle(cornerRadius: 35)
											.fill(.primary.opacity(0.05))
											.frame(width: geo.size.width * (isPortrait ? 0.83 : 0.86), height: geo.size.height * (isPortrait ? 0.8 : 0.89))
									)
							}
							HStack(spacing: geo.size.width * 0.15) {
								Button {
									swipe(.left)
								} label: {
									Image(systemName: "xmark")
										.font(.system(size: 35, weight: .semibold))
										.foregroundStyle(.red)
										.frame(width: 70, height: 70)
										.glassEffect(.regular.interactive())
								}
								Button {
									swipe(.right)
								} label: {
									Image(systemName: "checkmark")
										.font(.system(size: 35, weight: .semibold))
										.foregroundStyle(.green)
										.frame(width: 70, height: 70)
										.glassEffect(.regular.interactive())
								}
							}
							.disabled(isSwiping)
						}
					}
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
			.navigationDestination(isPresented: $showTimeTrialResult) {
				TimeTrialResultView(cards: cards, results: swipeResults)
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
	
	private func flashcard(card: Card, geo: GeometryProxy, isPortrait: Bool) -> some View {
		
		ZStack {
			RoundedRectangle(cornerRadius: 35, style: .continuous)
				.fill(.clear)
				.contentShape(RoundedRectangle(cornerRadius: 35, style: .continuous))
			RoundedRectangle(cornerRadius: 35, style: .continuous)
				.stroke(.primary.opacity(0.1), lineWidth: 2)
			VStack(spacing: 24) {
				Spacer()
				Text("\(card.frontEntry)")
					.font(.system(size: geo.size.width * (isPortrait ? 0.06 : 0.04), weight: .semibold))
					.foregroundStyle(.primary)
				if isCardTapped && preferences.trialMode != .death {
					Text("\(card.backEntry)")
						.font(.system(size: geo.size.width * (isPortrait ? 0.05 : 0.03), weight: .semibold))
						.foregroundStyle(.secondary)
				}
				if !isPortrait {
					Spacer()
				}
				Spacer()
			}
			.multilineTextAlignment(.center)
			.animation(.easeInOut(duration: 0.1), value: isCardTapped)
			RoundedRectangle(cornerRadius: 35, style: .continuous)
				.fill(LinearGradient(colors: [.red.opacity(Double(-dragOffset.width / 200)), .red.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
				.opacity(dragOffset.width < 0 ? 1 : 0)
			RoundedRectangle(cornerRadius: 35, style: .continuous)
				.fill(LinearGradient(colors: [.green.opacity(Double(dragOffset.width / 200)), .green.opacity(0.0)], startPoint: .trailing, endPoint: .leading))
				.opacity(dragOffset.width > 0 ? 1 : 0)
			TimerView(size: (isPortrait ? 70 : 20), duration: timeInterval, remainingTime: remainingTime, color: UIColor.label)
				.offset(y: geo.size.height * 0.25)
		}
		.frame(width: geo.size.width * (isPortrait ? 0.9 : 0.9), height: geo.size.height * (isPortrait ? 0.85 : 1.0))
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
		.shadow(color: .black.opacity(0.3), radius: 15)
		.onTapGesture {
			isCardTapped.toggle()
		}
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
			Text("\(selectedDeck?.name ?? "Every Card")")
				.font(.headline)
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				//
			} label: {
				Text("\(min(currentIndex + 1, cards.count))/\(cards.count)")
			}
		}
	}
}

/// SwipeDirection
fileprivate extension TimeTrialView {
	
	private func swipe(_ direction: SwipeDirection) {
		
		guard !isSwiping else { return }
		isSwiping = true
		swipeResults.append(direction)
		hasTimerPaused = true
		
		withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
			dragOffset.width = direction == .right ? 900 : -900
			rotation = direction == .right ? 14 : -14
		}
		
		Task { @MainActor in
			self.currentIndex += 1
			if self.currentIndex >= cards.count {
				showTimeTrialResult.toggle()
			}
			self.isCardTapped = false
			self.dragOffset = .zero
			self.rotation = 0
			self.hasTimerReachedZero = false
			self.hasTimerPaused = false
			self.remainingTime = timeInterval
			self.isSwiping = false
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
	
	private var backgroundGradient: some View {
		VStack {}
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
	
	return TimeTrialView(cards: cards, timeInterval: 1.5)
}
