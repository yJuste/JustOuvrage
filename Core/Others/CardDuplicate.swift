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
	}
	
	func removeDuplicates() throws {
		
		let cards = try modelContext.fetch(FetchDescriptor<Card>(sortBy: [SortDescriptor(\.createdAt, order: .forward)]))
		let grouped = Dictionary(grouping: cards) { card in
			Keys(frontEntry: card.frontEntry, backEntry: card.backEntry, frontLanguage: card.frontLanguage, backLanguage: card.backLanguage)
		}
		
		for (_, duplicates) in grouped where duplicates.count > 1 {
			guard let keep = duplicates.min(by: { $0.createdAt < $1.createdAt }) else { continue }
			
			for card in duplicates where card.id != keep.id {
				modelContext.delete(card)
			}
		}
		try modelContext.save()
	}
}
