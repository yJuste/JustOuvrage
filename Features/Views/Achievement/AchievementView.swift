//
//  AchievementView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/1/26.
//

import SwiftUI
import SwiftData

struct AchievementView: View {
	
	@Query private var cards: [Card]
	@Query private var decks: [Deck]
	
	let achievement: Achievements
	let context: AchievementContext
	let action: () -> Void
	
	var body: some View {
		let pourcentage = achievement.pourcentage(in: context)
		return HStack(spacing: 8) {
			VStack(alignment: .leading, spacing: 5) {
				Text(achievement.title)
				Text(achievement.shortDescription)
					.foregroundStyle(.secondary)
			}
			.font(.subheadline)
			Spacer()
			HStack(spacing: 10) {
				Text(pourcentage, format: .percent.precision(.fractionLength(0...2)))
					.font(.caption)
					.foregroundStyle(.secondary)
				ZStack(alignment: .bottom) {
					Button {
						action()
					} label: {
						Image(systemName: "trophy")
							.font(.title)
							.foregroundStyle(Color.black)
							.padding(12)
							.background(Circle().glassEffect(.clear.tint(achievement.isUnlocked(pourcentage: pourcentage) ? .yellow : .clear).interactive()))
					}
					.buttonStyle(.plain)
					if achievement.isUnlocked(pourcentage: pourcentage) {
						Image(systemName: "circle.fill")
							.font(.caption2)
							.offset(y: 5)
					}
				}
			}
		}
		.padding()
		.background(RoundedRectangle(cornerRadius: 18).fill(.secondary.opacity(0.2)))
		.onTapGesture {
			action()
		}
	}
}
