//
//  TimeTrialView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/7/26.
//

import SwiftUI

struct TimeTrialView: View {
	
	let cards: [Card]
	let cardDuration: TimeInterval = 3
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var currentIndex: Int = 0
	@State private var dragOffset: CGSize = .zero
	@State private var rotation: Double = 0
	@State private var progress: CGFloat = 1.0
	@State private var isFlipped = false
	@State private var timer: Timer?
	
	var currentCard: Card? {
		guard currentIndex < cards.count else { return nil }
		return cards[currentIndex]
	}
	
	var body: some View {
		ZStack {
			
			LinearGradient(
				colors: [
					Color.blue.opacity(0.25),
					Color.purple.opacity(0.20),
					Color.black
				],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
			.ignoresSafeArea()
			
			// Floating blurry circles
			Circle()
				.fill(.blue.opacity(0.18))
				.frame(width: 300)
				.blur(radius: 60)
				.offset(x: -160, y: -280)
			
			Circle()
				.fill(.purple.opacity(0.18))
				.frame(width: 260)
				.blur(radius: 60)
				.offset(x: 170, y: 250)
			
			VStack(spacing: 24) {
				
				header
				
				Spacer()
				
				if let card = currentCard {
					
					ZStack {
						
						// Next card preview
						RoundedRectangle(cornerRadius: 38, style: .continuous)
							.fill(.ultraThinMaterial)
							.overlay {
								RoundedRectangle(cornerRadius: 38)
									.stroke(.white.opacity(0.08), lineWidth: 1)
							}
							.scaleEffect(0.94)
							.opacity(0.45)
							.padding(.horizontal, 28)
						
						flashcard(card)
					}
					.transition(.asymmetric(
						insertion: .scale.combined(with: .opacity),
						removal: .scale(scale: 0.7).combined(with: .opacity)
					))
					
				} else {
					
					finishedView
				}
				
				Spacer()
				
				footer
			}
			.padding()
		}
		.navigationBarBackButtonHidden()
		.toolbar(.hidden, for: .tabBar)
		.onAppear {
			startTimer()
		}
		.onDisappear {
			timer?.invalidate()
		}
	}
}

private extension TimeTrialView {
	
	var header: some View {
		VStack(spacing: 14) {
			
			HStack {
				
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark")
						.font(.headline)
						.foregroundStyle(.white)
						.frame(width: 42, height: 42)
						.background(.ultraThinMaterial)
						.clipShape(Circle())
				}
				
				Spacer()
				
				Text("\(min(currentIndex + 1, cards.count))/\(cards.count)")
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(.white.opacity(0.8))
					.padding(.horizontal, 14)
					.padding(.vertical, 8)
					.background(.ultraThinMaterial)
					.clipShape(Capsule())
			}
			
			// Timer progress
			GeometryReader { geo in
				
				ZStack(alignment: .leading) {
					
					Capsule()
						.fill(.white.opacity(0.08))
					
					Capsule()
						.fill(
							LinearGradient(
								colors: [.blue, .purple],
								startPoint: .leading,
								endPoint: .trailing
							)
						)
						.frame(width: geo.size.width * progress)
				}
			}
			.frame(height: 8)
		}
	}
	
	func flashcard(_ card: Card) -> some View {
		
		ZStack {
			
			RoundedRectangle(cornerRadius: 38, style: .continuous)
				.fill(.ultraThinMaterial)
			
			RoundedRectangle(cornerRadius: 38, style: .continuous)
				.stroke(.white.opacity(0.10), lineWidth: 1)
			
			VStack(spacing: 24) {
				
				Spacer()
				
				Text(card.frontEntry)
					.font(.system(size: 34, weight: .bold, design: .rounded))
					.multilineTextAlignment(.center)
					.foregroundStyle(.white)
					.padding(.horizontal)
				
				Spacer()
				
				HStack(spacing: 18) {
					
					swipeIndicator(
						icon: "xmark",
						title: "Wrong",
						color: .red
					)
					
					swipeIndicator(
						icon: "checkmark",
						title: "Correct",
						color: .green
					)
				}
				.padding(.bottom, 26)
			}
		}
		.frame(height: 520)
		.overlay(alignment: .topLeading) {
			
			Image(systemName: "xmark")
				.font(.system(size: 80, weight: .black))
				.foregroundStyle(.red)
				.opacity(dragOffset.width < -40 ? 1 : 0)
				.padding(30)
		}
		.overlay(alignment: .topTrailing) {
			
			Image(systemName: "checkmark")
				.font(.system(size: 80, weight: .black))
				.foregroundStyle(.green)
				.opacity(dragOffset.width > 40 ? 1 : 0)
				.padding(30)
		}
		.padding(.horizontal, 18)
		.offset(x: dragOffset.width, y: dragOffset.height)
		.rotationEffect(.degrees(rotation))
		.gesture(
			DragGesture()
				.onChanged { value in
					
					dragOffset = value.translation
					
					rotation = value.translation.width / 18
				}
				.onEnded { value in
					
					let horizontal = value.translation.width
					
					if horizontal > 120 {
						swipe(.right)
					} else if horizontal < -120 {
						swipe(.left)
					} else {
						
						withAnimation(.spring(
							response: 0.45,
							dampingFraction: 0.82
						)) {
							dragOffset = .zero
							rotation = 0
						}
					}
				}
		)
		.shadow(
			color: .black.opacity(0.22),
			radius: 30,
			y: 20
		)
	}
	
	var footer: some View {
		
		HStack(spacing: 18) {
			
			actionButton(
				icon: "xmark",
				color: .red
			) {
				swipe(.left)
			}
			
			actionButton(
				icon: "checkmark",
				color: .green
			) {
				swipe(.right)
			}
		}
	}
	
	var finishedView: some View {
		
		VStack(spacing: 22) {
			
			Image(systemName: "sparkles")
				.font(.system(size: 64))
				.foregroundStyle(.white)
			
			Text("Session Complete")
				.font(.largeTitle.bold())
				.foregroundStyle(.white)
			
			Button {
				
				dismiss()
				
			} label: {
				
				Text("Done")
					.fontWeight(.semibold)
					.foregroundStyle(.black)
					.padding(.horizontal, 28)
					.padding(.vertical, 14)
					.background(.white)
					.clipShape(Capsule())
			}
		}
	}
}

private extension TimeTrialView {
	
	enum SwipeDirection {
		case left
		case right
	}
	
	func swipe(_ direction: SwipeDirection) {
		
		timer?.invalidate()
		
		let x: CGFloat = direction == .right ? 900 : -900
		
		withAnimation(.spring(
			response: 0.35,
			dampingFraction: 0.8
		)) {
			
			dragOffset.width = x
			rotation = direction == .right ? 14 : -14
		}
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
			
			currentIndex += 1
			
			dragOffset = .zero
			rotation = 0
			progress = 1
			
			if currentIndex < cards.count {
				startTimer()
			}
		}
	}
	
	func startTimer() {
		
		progress = 1
		
		timer?.invalidate()
		
		withAnimation(.linear(duration: cardDuration)) {
			progress = 0
		}
		
		timer = Timer.scheduledTimer(withTimeInterval: cardDuration, repeats: false) { _ in
			swipe(.left)
		}
	}
	
	func actionButton(
		icon: String,
		color: Color,
		action: @escaping () -> Void
	) -> some View {
		
		Button(action: action) {
			
			Image(systemName: icon)
				.font(.title2.bold())
				.foregroundStyle(.white)
				.frame(width: 68, height: 68)
				.background(.ultraThinMaterial)
				.overlay {
					Circle()
						.stroke(color.opacity(0.4), lineWidth: 1.2)
				}
				.clipShape(Circle())
		}
	}
	
	func swipeIndicator(
		icon: String,
		title: String,
		color: Color
	) -> some View {
		
		HStack(spacing: 8) {
			
			Image(systemName: icon)
			
			Text(title)
		}
		.font(.subheadline.weight(.semibold))
		.foregroundStyle(color)
		.padding(.horizontal, 14)
		.padding(.vertical, 10)
		.background(.white.opacity(0.06))
		.clipShape(Capsule())
	}
}

#Preview {
	
	let sampleCards: [Card] = (1...10).map { index in
		Card(
			frontEntry: "Sample Front \(index)",
			backEntry: "Exemple Dos \(index)",
			frontLanguage: .en_US,
			backLanguage: .fr_CA
		)
	}
	return TimeTrialView(cards: sampleCards)
}
