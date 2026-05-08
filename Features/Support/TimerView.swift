//
//  TimerView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/8/26.
//

import SwiftUI

/// Minimum size 100
struct TimerView: View {
	
	let size: CGFloat
	let duration: TimeInterval
	let color: UIColor
	
	@Binding var isPaused: Bool
	@Binding var isFinished: Bool
	
	var restartTrigger: UUID
	var onFinished: (() -> Void)?
	
	@State private var startDate: Date?
	@State private var endDate: Date?
	@State private var remainingTime: TimeInterval = 0
	@State private var progress: CGFloat = 1
	@State private var pausedRemaining: TimeInterval?
	
	var body: some View {
		ZStack {
			Circle()
				.stroke(Color(uiColor: color).opacity(0.15), lineWidth: 8)
			
			Circle()
				.trim(from: 0, to: progress)
				.stroke(
					Color(uiColor: color),
					style: StrokeStyle(lineWidth: 8, lineCap: .round)
				)
				.rotationEffect(.degrees(-90))
			
			GeometryReader { geo in
				Text("\(max(Int(ceil(remainingTime.rounded(.up))), 0))")
					.font(.system(size: geo.size.width * 0.8, weight: .bold, design: .rounded))
					.frame(width: geo.size.width, height: geo.size.height)
					.contentTransition(.numericText())
					.minimumScaleFactor(0.1)
			}
			.padding(20)
		}
		.frame(width: max(size, 100), height: max(size, 100))
		.animation(.linear(duration: 0.1), value: progress)
		.task {
			start()
			await timer()
		}
		.onChange(of: restartTrigger) {
			start()
		}
	}
	
	private func start() {
		startDate = Date()
		endDate = startDate?.addingTimeInterval(duration)
		remainingTime = duration
		progress = 1
		isFinished = false
		isPaused = false
		pausedRemaining = nil
	}
	
	private func timer() async {
		
		while true {
			if isFinished {
				try? await Task.sleep(for: .milliseconds(16))
				continue
			}
			if isPaused {
				if pausedRemaining == nil {
					pausedRemaining = remainingTime
				}
				try? await Task.sleep(for: .milliseconds(100))
				continue
			}
			if let pausedRemaining {
				endDate = Date().addingTimeInterval(pausedRemaining)
				self.pausedRemaining = nil
			}
			guard let endDate else {
				try? await Task.sleep(for: .milliseconds(16))
				continue
			}
			let now = Date()
			let remaining = endDate.timeIntervalSince(now)
			
			remainingTime = max(remaining, 0)
			progress = max(remaining / duration, 0)
			if remaining <= 0 {
				remainingTime = 0
				progress = 0
				isFinished = true
				isPaused = true
				onFinished?()
			}
			try? await Task.sleep(for: .milliseconds(16))
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
					duration: 3,
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
