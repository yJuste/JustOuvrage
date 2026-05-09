//
//  TimerView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/8/26.
//

import SwiftUI

/// Minimum size 100
@MainActor
struct TimerView: View {
	
	let size: CGFloat
	let duration: TimeInterval
	let color: UIColor
	@Binding var isPaused: Bool
	@Binding var isFinished: Bool
	var restartTrigger: UUID
	var onFinished: (() -> Void)?
	
	@State private var startDate = Date()
	@State private var pauseDate: Date?
	
	var body: some View {
		
		TimelineView(.animation) { context in
			
			let elapsed: TimeInterval = {
				if let pauseDate {
					return pauseDate.timeIntervalSince(startDate)
				} else {
					return context.date.timeIntervalSince(startDate)
				}
			}()
			let remaining = max(duration - elapsed, 0)
			let length = max(size, 100)
			
			ZStack {
				Circle()
					.stroke(Color(uiColor: color).opacity(0.15), lineWidth: 8)
				Circle()
					.trim(from: 0, to: max(remaining / duration, 0))
					.stroke(Color(uiColor: color), style: StrokeStyle(lineWidth: 8, lineCap: .round))
					.rotationEffect(.degrees(-90))
				Text("\(Int(ceil(remaining)))")
					.font(.system(size: 60, weight: .semibold, design: .rounded))
					.lineLimit(1)
			}
			.frame(width: length, height: length)
			.onChange(of: restartTrigger) {
				start()
			}
			.onChange(of: isPaused) {
				pause($1)
			}
			.onChange(of: remaining) {
				if $1 <= 0, !isFinished {
					isFinished = true
					isPaused = true
					onFinished?()
				}
			}
		}
	}
}

/// Methods of TimerView.
fileprivate extension TimerView {
	
	private func start() {
		startDate = Date()
		pauseDate = nil
		isPaused = false
		isFinished = false
	}
	
	private func pause(_ paused: Bool) {
		if paused {
			pauseDate = Date()
		} else {
			if let pauseDate {
				let pauseDuration = Date().timeIntervalSince(pauseDate)
				startDate = startDate.addingTimeInterval(pauseDuration)
			}
			self.pauseDate = nil
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
