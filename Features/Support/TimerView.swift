//
//  TimerView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/8/26.
//

import SwiftUI

/// Minimum size 100
@MainActor struct TimerView: View {
	
	let size: CGFloat
	let duration: TimeInterval
	let color: UIColor
	@Binding var isPaused: Bool
	@Binding var isFinished: Bool
	var restartTrigger: UUID
	var onFinished: (() -> Void)?
	
	@State private var deadline: Date?
	@State private var pausedRemaining: TimeInterval?
	
	var body: some View {
		
		TimelineView(.animation) { context in
			
			let remaining = timeRemaining(now: context.date)
			let length = max(size, 100)
			
			ZStack {
				Circle()
					.stroke(Color(uiColor: color).opacity(0.15), lineWidth: 8)
				Circle()
					.trim(from: 0, to: max(remaining / duration, 0))
					.stroke(Color(uiColor: color), style: StrokeStyle(lineWidth: 8, lineCap: .round))
					.rotationEffect(.degrees(-90))
				Text("\(Int(ceil(remaining)))")
					.font(.system(size: size * 0.35, weight: .bold, design: .rounded))
					.monospacedDigit()
					.minimumScaleFactor(0.2)
			}
			.onChange(of: remaining) { _, value in
				if value <= 0 && !isFinished {
					isFinished = true
					isPaused = true
					onFinished?()
				}
			}
			.frame(width: length, height: length)
		}
		.onChange(of: isPaused) { _, paused in
			timePaused(paused: paused)
		}
		.task(id: restartTrigger) { reset() }
	}
}

/// Methods of TimerView.
fileprivate extension TimerView {
	
	private func reset() {
		deadline = Date().addingTimeInterval(duration)
		pausedRemaining = nil
		isPaused = false
		isFinished = false
	}
	
	private func timeRemaining(now: Date) -> TimeInterval {
		
		if isPaused { return pausedRemaining ?? 0 }
		guard let deadline else { return 0 }
		return max(deadline.timeIntervalSince(now), 0)
	}
	
	private func timePaused(paused: Bool) {
		
		if paused {
			guard let deadline else { return }
			pausedRemaining = max(deadline.timeIntervalSince(Date()), 0)
		} else {
			deadline = Date().addingTimeInterval(pausedRemaining ?? 0)
			pausedRemaining = nil
		}
	}
}

#Preview {
	
	struct TimerPreviewWrapper: View {
		
		@State private var isPaused: Bool = false
		@State private var isFinished: Bool = false
		@State private var timerID = UUID()
		
		var body: some View {
			VStack(spacing: 20) {
				TimerView(
					size: 100,
					duration: 5,
					color: .accent,
					isPaused: $isPaused,
					isFinished: $isFinished,
					restartTrigger: timerID,
					onFinished: nil
				)
				Button(isPaused ? "Resume" : "Stop") {
					isPaused.toggle()
				}
				.buttonStyle(.borderedProminent)
				.tint(isPaused ? .green : .red)
			}
		}
	}
	return TimerPreviewWrapper()
}
