//
//  TimerView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/8/26.
//

// MARK: Worst function I ever made.

import SwiftUI

/// Minimum size = 100
struct TimerView: View {
	
	let size: CGFloat
	let duration: TimeInterval
	let remainingTime: TimeInterval
	let color: UIColor
	
	var body: some View {
		
		let length: CGFloat = max(size, 70)
		
		GeometryReader { geo in
			
			let side: CGFloat = min(geo.size.width, geo.size.height)
			let stroke: CGFloat = side * 0.1
			
			ZStack {
				Circle()
					.stroke(Color(uiColor: color).opacity(0.15), lineWidth: stroke)
				Circle()
					.trim(from: 0, to: max(remainingTime / duration, 0))
					.stroke(Color(uiColor: color), style: StrokeStyle(lineWidth: stroke, lineCap: .round))
					.rotationEffect(.degrees(-90))
				Text(remainingTime < Constants.infinityDay ? "\(Int(ceil(remainingTime)))" : "∞")
				.font(.system(size: side * 0.5, weight: .bold, design: .rounded))
				.minimumScaleFactor(0.01)
				.lineLimit(1)
				.padding(side * 0.12)
			}
			.frame(width: side, height: side)
		}
		.frame(width: length, height: length)
	}
}

#Preview {
	TimerView(size: 100, duration: 10, remainingTime: 20, color: .blue)
}
