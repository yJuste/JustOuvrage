//
//  CardDuplication.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/14/26.
//

import SwiftUI
import SwiftData

/// Deletes card duplications.
struct CardDuplication {
	
	private struct Key: Hashable {
		
		let front: String
		let back: String
		let frontLanguage: Language
		let backLanguage: Language
		
		init(card: Card) {
			self.front = card.frontEntry
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.lowercased()
			self.back = card.backEntry
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.lowercased()
			self.frontLanguage = card.frontLanguage
			self.backLanguage = card.backLanguage
		}
	}
	
	static func removeDuplicates(in modelContext: ModelContext) throws {
		
		let cards: [Card] = try modelContext.fetch(FetchDescriptor<Card>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)]))
		var seen: Set = Set<Key>()
		var duplicates: [Card] = []
		
		for card in cards {
			if seen.insert(Key(card: card)).inserted == false {
				duplicates.append(card)
			}
		}
		
		duplicates.forEach(modelContext.delete)
		try modelContext.save()
	}
}

