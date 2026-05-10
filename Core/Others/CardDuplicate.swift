//
//  CardDuplicate.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/10/26.
//

import SwiftUI
import SwiftData

@ModelActor actor CardDuplicate {
	
	private struct Keys: Hashable {
		
		let frontEntry: String
		let backEntry: String
		let frontLanguage: Language
		let backLanguage: Language
		
		init(card: Card) {
			self.frontEntry = card.frontEntry
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.lowercased()
			
			self.backEntry = card.backEntry
				.trimmingCharacters(in: .whitespacesAndNewlines)
				.lowercased()
			
			self.frontLanguage = card.frontLanguage
			self.backLanguage = card.backLanguage
		}
	}
	
	func removeDuplicates() throws {
		
		let cards = try modelContext.fetch(
			FetchDescriptor<Card>(
				sortBy: [SortDescriptor(\.createdAt, order: .forward)]
			)
		)
		
		let grouped = Dictionary(grouping: cards) {
			Keys(card: $0)
		}
		
		for (_, duplicates) in grouped where duplicates.count > 1 {
			
			for card in duplicates.dropFirst() {
				modelContext.delete(card)
			}
		}
		
		try modelContext.save()
	}
}
