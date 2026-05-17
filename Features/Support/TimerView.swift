//
//  TimerView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/8/26.
//

// MARK: Worst function I ever made.

import SwiftUI

/// Minimum size = 100
@MainActor struct TimerView: View {
	
	let size: CGFloat
	let duration: TimeInterval
	let color: UIColor
	@Binding var isPaused: Bool
	@Binding var isFinished: Bool
	var restartTrigger: UUID
	
	@State private var startDate: Date = Date()
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
			let remaining = duration - elapsed
			let length = max(size, 70)
			
			ZStack {
				Circle()
					.stroke(Color(uiColor: color).opacity(0.15), lineWidth: 8)
				Circle()
					.trim(from: 0, to: max(remaining / duration, 0))
					.stroke(Color(uiColor: color), style: StrokeStyle(lineWidth: 8, lineCap: .round))
					.rotationEffect(.degrees(-90))
				GeometryReader { geo in
					Text("\(Int(ceil(remaining)))")
						.font(.system(size: min(geo.size.width, geo.size.height), weight: .semibold, design: .rounded))
						.minimumScaleFactor(0.01)
						.lineLimit(1)
						.frame(width: geo.size.width, height: geo.size.height)
				}
				.padding(8)
			}
			.onChange(of: remaining) {
				if $1 <= 0 {
					isFinished = true
					isPaused = true
				}
			}
			.onChange(of: isPaused) {
				pause($1)
			}
			.onChange(of: restartTrigger) {
				start()
			}
			.frame(width: length, height: length)
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
				startDate += Date().timeIntervalSince(pauseDate)
			}
			self.pauseDate = nil
		}
	}
}

#Preview {
	
	struct TimerPreviewWrapper: View {
		
		@State private var isPaused: Bool = false
		@State private var isFinished: Bool = false
		@State private var istimer: UUID = UUID()
		
		var body: some View {
			VStack(spacing: 20) {
				TimerView(
					size: 70,
					duration: 9,
					color: .accent,
					isPaused: $isPaused,
					isFinished: $isFinished,
					restartTrigger: istimer
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
