//
//  Leitner.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/26/26.
//

import SwiftUI

enum Leitner {
	
	static let minimumScore = 1
	static let maximumScore = 7
	
	static func due(from cards: [Card]) -> [Card] {
		cards.filter { card in
			guard let nextLeitnerAt = card.nextLeitnerAt else { return true }
			return Date.now >= nextLeitnerAt
		}
	}
	
	static func next(from cards: [Card]) -> String {
		
		if !due(from: cards).isEmpty { return "Now!" }
		
		guard let closestDate = cards.compactMap(\.nextLeitnerAt).min() else { return "Now!" }
		
		let interval = closestDate.timeIntervalSinceNow
		
		if interval <= 0 { return "Now!" }
		
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .abbreviated
		formatter.maximumUnitCount = 1
		
		switch interval {
		case ..<60: formatter.allowedUnits = [.second]
		case ..<3600: formatter.allowedUnits = [.minute]
		case ..<86400: formatter.allowedUnits = [.hour]
		default: formatter.allowedUnits = [.day]
		}
		return formatter.string(from: interval) ?? "Soon"
	}
	
	static func update(for card: Card, score: Int) {
		
		card.leitnerScore = min(max(score, minimumScore), maximumScore)
		
		if card.leitnerScore == 1 {
			card.nextLeitnerAt = .now
		} else {
			card.nextLeitnerAt = Calendar.current.date(byAdding: .day, value: card.leitnerScore, to: .now)
		}
	}
}
