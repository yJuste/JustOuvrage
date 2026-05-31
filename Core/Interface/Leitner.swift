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
			guard card.leitnerScore < maximumScore else { return false }
			guard let nextLeitnerAt = card.nextLeitnerAt else { return true }
			return Date.now >= nextLeitnerAt
		}
	}
	
	static func next(from cards: [Card]) -> String {
		
		let activeCards = cards.filter { $0.leitnerScore < maximumScore }
		
		if !due(from: activeCards).isEmpty { return "Now!" }
		
		guard let closestDate = activeCards.compactMap(\.nextLeitnerAt).min() else { return "Completed!" }
		
		let interval = closestDate.timeIntervalSinceNow
		
		if interval <= 0 { return "Now!" }
		
		let seconds = Int(interval)
		
		switch seconds {
		case ..<60: return "\(seconds)s"
		case ..<3600: return "\(seconds / 60)m"
		case ..<86400: return "\(seconds / 3600)h"
		default: return "\(seconds / 86400)d"
		}
	}
	
	static func update(for card: Card, score: Int) {
		
		card.leitnerScore = min(max(score, minimumScore), maximumScore)
		let score = card.leitnerScore
		
		if score == maximumScore { card.nextLeitnerAt = nil; return }
		
		if score == 1 {
			card.nextLeitnerAt = .now
		} else {
			card.nextLeitnerAt = Calendar.current.date(byAdding: .day, value: score, to: .now)
		}
	}
}
