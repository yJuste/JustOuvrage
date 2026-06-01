//
//  Achievements.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/1/26.
//

enum Achievements: Identifiable, CaseIterable {
	
	case oneThousandCards
	case tenThousandCards
	
	var id: Self { self }
	
	var title: String {
		switch self {
		case .oneThousandCards: return "The Seeker"
		case .tenThousandCards: return "The Tryharder"
		}
	}
	
	var description: String {
		switch self {
		case .oneThousandCards: return "You have to have at least 1 000 cards in the application in total."
		case .tenThousandCards: return "You have to have at least 10 000 cards in the application in total."
		}
	}
	
	func pourcentage(in context: AchievementContext) -> Double {
		switch self {
		case .oneThousandCards: return min(Double(context.cards.count) / 1_000.0, 1.0)
		case .tenThousandCards: return min(Double(context.cards.count) / 10_000.0, 1.0)
		}
	}
	
	func isUnlocked(in context: AchievementContext) -> Bool {
		pourcentage(in: context) >= 1.0
	}
	
	func isUnlocked(pourcentage: Double) -> Bool {
		pourcentage >= 1.0
	}
}
