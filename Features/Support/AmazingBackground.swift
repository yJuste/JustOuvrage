//
//  AmazingBackground.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/25/26.
//

import SwiftUI

import SwiftUI

struct AmazingBackground: View {
	
	let colors: [Color]
	let active: Bool
	
	@State private var animate = false
	@State private var flame1Start: CGSize = .zero
	@State private var flame1End: CGSize = .zero
	@State private var flame2Start: CGSize = .zero
	@State private var flame2End: CGSize = .zero
	@State private var flame3Start: CGSize = .zero
	@State private var flame3End: CGSize = .zero
	@State private var angle1: Double = Double.random(in: -45 ... -20)
	@State private var angle2: Double = Double.random(in: -40 ... -15)
	@State private var angle3: Double = Double.random(in: 10 ... 35)
	@State private var didSetup = false
	
	var body: some View {
		GeometryReader { geo in
			let size = geo.size
			let height = size.height
			let width = size.width
			ZStack {
				LinearGradient(gradient: Gradient(colors: colors), startPoint: .bottomLeading, endPoint: .topTrailing)
				FlameShape.shared
					.fill(
						LinearGradient(colors: [colors.first?.opacity(0.40) ?? .black, colors.last?.opacity(0.20) ?? .black, .clear], startPoint: .bottom, endPoint: .top)
					)
					.frame(width: 160, height: 720)
					.blur(radius: 28)
					.rotationEffect(.degrees(angle1))
					.offset(flame1Offset)
					.scaleEffect(x: animate ? 1.015 : 0.985, y: animate ? 1.03 : 0.97)
					.animation(active ? .easeInOut(duration: 22).repeatForever(autoreverses: true) : nil, value: animate)
					.blendMode(.screen)
				FlameShape.shared
					.fill(LinearGradient(colors: [colors.last?.opacity(0.26) ?? .black, .clear], startPoint: .bottom, endPoint: .top))
					.frame(width: 110, height: 500)
					.blur(radius: 20)
					.rotationEffect(.degrees(angle2))
					.offset(flame2Offset)
					.scaleEffect(x: animate ? 1.01 : 0.99, y: animate ? 1.02 : 0.98)
					.animation(active ? .easeInOut(duration: 28).repeatForever(autoreverses: true) : nil, value: animate)
					.blendMode(.screen)
				FlameShape.shared
					.fill(LinearGradient(colors: [colors.first?.opacity(0.45) ?? .black, colors.last?.opacity(0.20) ?? .black, .clear], startPoint: .bottom, endPoint: .top))
					.frame(width: 45, height: 650)
					.blur(radius: 20)
					.rotationEffect(.degrees(angle3))
					.offset(x: -width * 0.22, y: -height * 0.40)
					.scaleEffect(x: animate ? 1.02 : 0.98, y: animate ? 1.08 : 0.92)
					.opacity(0.65)
					.animation(active ? .easeInOut(duration: 24).repeatForever(autoreverses: true) : nil, value: animate)
					.blendMode(.screen)
			}
			.compositingGroup()
			.onAppear {
				guard !didSetup else { return }
				didSetup = true
				flame1Start = randomStart(in: size)
				flame1End = randomEnd(from: flame1Start, in: size)
				flame2Start = randomStart(in: size)
				flame2End = randomEnd(from: flame2Start, in: size)
				flame3Start = CGSize(width: -width * 0.1, height: -height * 0.2)
				flame3End = CGSize(width: flame3Start.width + 30, height: flame3Start.height + 120)
				animate = active
			}
			.onChange(of: active) { _, newValue in
				animate = newValue
			}
		}
	}
	
	private var flame1Offset: CGSize { animate ? flame1End : flame1Start }
	private var flame2Offset: CGSize { animate ? flame2End : flame2Start }
	private var flame3Offset: CGSize { animate ? flame3End : flame3Start }
	
	private func randomStart(in size: CGSize) -> CGSize {
		CGSize(
			width: CGFloat.random(in: -size.width * 0.15 ... size.width * 0.55),
			height: CGFloat.random(in: size.height * 0.05 ... size.height * 0.45)
		)
	}
	
	private func randomEnd(from start: CGSize, in size: CGSize) -> CGSize {
		CGSize(
			width: start.width + CGFloat.random(in: 40 ... 140),
			height: start.height - CGFloat.random(in: 120 ... 280)
		)
	}
}

/// Methods of AmazingBackground.
fileprivate extension AmazingBackground {
	
	struct FlameShape: Shape {
		
		static let shared = FlameShape()
		
		func path(in rect: CGRect) -> Path {
			var path = Path()
			path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
			path.addCurve(
				to: CGPoint(x: rect.midX, y: rect.minY),
				control1: CGPoint(x: rect.minX - rect.width * 0.35, y: rect.height * 0.75),
				control2: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.height * 0.2)
			)
			path.addCurve(
				to: CGPoint(x: rect.midX, y: rect.maxY),
				control1: CGPoint(x: rect.maxX - rect.width * 0.1, y: rect.height * 0.25),
				control2: CGPoint(x: rect.maxX + rect.width * 0.28, y: rect.height * 0.82)
			)
			return path
		}
	}
}
