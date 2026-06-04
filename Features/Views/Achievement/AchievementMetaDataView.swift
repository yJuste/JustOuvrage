//
//  AchievementMetaDataView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/1/26.
//

import SwiftUI
import SwiftData

struct AchievementMetaDataView: View {
	
	let achievement: Achievements
	let context: AchievementContext
	
	@Query private var cards: [Card]
	@Query private var decks: [Deck]
	
	var body: some View {
		NavigationStack {
			let pourcentage = achievement.pourcentage(in: context)
			let _ = achievement.isUnlocked(pourcentage: pourcentage)
			ScrollView {
				VStack(alignment: .leading, spacing: 15) {
					Text(achievement.description)
					Text(pourcentage, format: .percent.precision(.fractionLength(0...2)))
				}
				.padding(15)
			}
			.navigationTitle("Achievements")
			.navigationBarTitleDisplayMode(.inline)
		}
	}
}

#Preview {
	//AchievementMetaDataView(achievement: .oneThousandCards, context: AchievementContext(cards: cards, decks: decks))
}
