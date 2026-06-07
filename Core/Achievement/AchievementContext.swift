//
//  AchievementContext.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/1/26.
//

import Foundation

struct AchievementContext {
	
	let cards: [Card]
	let decks: [Deck]
	let timeTrials: [TimeTrial]
	let cleanupDate: Date?
	let profileName: String
}
