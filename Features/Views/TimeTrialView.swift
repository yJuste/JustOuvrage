//
//  TimeTrialView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/7/26.
//

import SwiftUI

struct TimeTrialView: View {
	
	let cards: [Card]
	let timeInterval: TimeInterval = 3
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var currentIndex: Int = 0
	@State private var hasTimerReachedZero: Bool = false
	@State private var hasTimerPaused: Bool = false
	@State private var dragOffset: CGSize = .zero
	@State private var rotation: Double = 0
	@State private var trigger: UUID = UUID()
	@State private var swipeResults: [SwipeDirection] = []
	@State private var showPause: Bool = false
	@State private var isSwiping: Bool = false
	
	var currentCard: Card? {
		guard currentIndex < cards.count else { return nil }
		return cards[currentIndex]
	}
	
	var body: some View {
		NavigationStack {
			ZStack {
				backgroundGradient
				VStack(spacing: 35) {
					if let card = currentCard {
						ZStack {
							backgroundDeck
							flashcard(card: card)
						}
						HStack(spacing: 40) {
							Button {
								swipe(.left)
							} label: {
								Image(systemName: "xmark")
									.font(.system(size: 35, weight: .semibold))
									.foregroundStyle(.red)
									.frame(width: 70, height: 70)
									.glassEffect(.regular.interactive())
							}
							.disabled(isSwiping)
							TimerView(size: 100, duration: timeInterval, color: UIColor.label, isPaused: $hasTimerPaused, isFinished: $hasTimerReachedZero, restartTrigger: trigger)
							Button {
								swipe(.right)
							} label: {
								Image(systemName: "checkmark")
									.font(.system(size: 35, weight: .semibold))
									.foregroundStyle(.green)
									.frame(width: 70, height: 70)
									.glassEffect(.regular.interactive())
							}
							.disabled(isSwiping)
						}
					} else {
						TimeTrialResultView()
					}
				}
			}
			.onChange(of: hasTimerReachedZero) { _, reached in
				guard reached else { return }
				swipe(.left)
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
	
	private func flashcard(card: Card) -> some View {
		
		ZStack {
			RoundedRectangle(cornerRadius: 35, style: .continuous)
				.fill(.ultraThinMaterial)
			RoundedRectangle(cornerRadius: 35, style: .continuous)
				.stroke(.white.opacity(0.1), lineWidth: 2)
			VStack(spacing: 24) {
				Spacer()
				Text(card.frontEntry)
					.font(.system(size: 30, weight: .semibold))
					.multilineTextAlignment(.center)
					.foregroundStyle(.primary)
					.padding(.horizontal)
				Spacer()
			}
			RoundedRectangle(cornerRadius: 35, style: .continuous)
				.fill(LinearGradient(colors: [.red.opacity(Double(-dragOffset.width / 200)), .red.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
				.opacity(dragOffset.width < 0 ? 1 : 0)
			RoundedRectangle(cornerRadius: 35, style: .continuous)
				.fill(LinearGradient(colors: [.green.opacity(Double(dragOffset.width / 200)), .green.opacity(0.0)], startPoint: .trailing, endPoint: .leading))
				.opacity(dragOffset.width > 0 ? 1 : 0)
		}
		.frame(height: 525)
		.padding(.horizontal, 25)
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
					if horizontal > 80 {
						swipe(.right)
					} else if horizontal < -80 {
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
			Text("[Deck Name]")
				.font(.title3)
				.fontWeight(.semibold)
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
	
	private enum SwipeDirection {
		
		case left
		case right
	}
	
	private func swipe(_ direction: SwipeDirection) {
		
		guard !isSwiping else { return }
		isSwiping = true
		swipeResults.append(direction)
		hasTimerPaused = true
		let x: CGFloat = direction == .right ? 900 : -900
		withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
			dragOffset.width = x
			rotation = direction == .right ? 14 : -14
		}
		DispatchQueue.main.async {
			currentIndex += 1
			dragOffset = .zero
			rotation = 0
			guard currentIndex < cards.count else {
				return isSwiping = false
			}
			hasTimerReachedZero = false
			hasTimerPaused = false
			trigger = UUID()
			isSwiping = false
		}
	}
}

/// Background for Gradient & Deck.
fileprivate extension TimeTrialView {
	
	var backgroundDeck: some View {
		RoundedRectangle(cornerRadius: 35, style: .continuous)
			.fill(.primary)
			.opacity(0.05)
			.padding(.horizontal, 30)
			.padding(.vertical, 70)
	}
	
	var backgroundGradient: some View {
		VStack {}
	}
}

#Preview {

	let cards: [Card] = (1...10).map { index in
		Card(
			frontEntry: "Sample Front \(index)",
			backEntry: "Exemple Dos \(index)",
			frontLanguage: .en_US,
			backLanguage: .fr_CA
		)
	}
	return TimeTrialView(cards: cards)
}
