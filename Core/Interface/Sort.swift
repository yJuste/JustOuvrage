//
//  Sort.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/19/26.
//

import SwiftUI
import Foundation

enum SortCard: String, CaseIterable, Codable, Hashable {
	
	case alphabeticalAscending
	case alphabeticalDescending
	case newestToOldest
	case oldestToNewest
	
	func compare(_ lhs: Card, _ rhs: Card) -> ComparisonResult? {
		switch self {
		case .alphabeticalAscending:
			let result = lhs.frontEntry.localizedStandardCompare(rhs.frontEntry)
			return result == .orderedSame ? nil : result
		case .alphabeticalDescending:
			let result = lhs.frontEntry.localizedStandardCompare(rhs.frontEntry)
			guard result != .orderedSame else { return nil }
			return result == .orderedAscending ? .orderedDescending : .orderedAscending
		case .newestToOldest:
			guard lhs.createdAt != rhs.createdAt else { return nil }
			return lhs.createdAt > rhs.createdAt ? .orderedAscending : .orderedDescending
		case .oldestToNewest:
			guard lhs.createdAt != rhs.createdAt else { return nil }
			return lhs.createdAt < rhs.createdAt ? .orderedAscending : .orderedDescending
		}
	}
}

enum SortDeck: String, CaseIterable, Codable, Hashable {
	
	case alphabeticalAscending
	case alphabeticalDescending
	case newestToOldest
	case oldestToNewest
	
	func compare(_ lhs: Deck, _ rhs: Deck) -> ComparisonResult? {
		switch self {
		case .alphabeticalAscending:
			let result = lhs.name.localizedStandardCompare(rhs.name)
			return result == .orderedSame ? nil : result
		case .alphabeticalDescending:
			let result = lhs.name.localizedStandardCompare(rhs.name)
			guard result != .orderedSame else { return nil }
			return result == .orderedAscending ? .orderedDescending : .orderedAscending
		case .newestToOldest:
			guard lhs.createdAt != rhs.createdAt else { return nil }
			return lhs.createdAt > rhs.createdAt ? .orderedAscending : .orderedDescending
		case .oldestToNewest:
			guard lhs.createdAt != rhs.createdAt else { return nil }
			return lhs.createdAt < rhs.createdAt ? .orderedAscending : .orderedDescending
		}
	}
}

enum SortTimeTrial: String, CaseIterable, Codable, Hashable {
	
	case alphabeticalAscending
	case alphabeticalDescending
	case newestToOldest
	case oldestToNewest
	
	func compare(_ lhs: TimeTrial, _ rhs: TimeTrial) -> ComparisonResult? {
		switch self {
		case .alphabeticalAscending:
			let result = (lhs.deck?.name ?? "").localizedStandardCompare(rhs.deck?.name ?? "")
			return result == .orderedSame ? nil : result
		case .alphabeticalDescending:
			let result = (lhs.deck?.name ?? "").localizedStandardCompare(rhs.deck?.name ?? "")
			guard result != .orderedSame else { return nil }
			return result == .orderedAscending ? .orderedDescending : .orderedAscending
		case .newestToOldest:
			guard lhs.createdAt != rhs.createdAt else { return nil }
			return lhs.createdAt > rhs.createdAt ? .orderedAscending : .orderedDescending
		case .oldestToNewest:
			guard lhs.createdAt != rhs.createdAt else { return nil }
			return lhs.createdAt < rhs.createdAt ? .orderedAscending : .orderedDescending
		}
	}
}

/// Interfaces to sort the cards in TimeTrialView.
enum SortTrial: Int, CaseIterable {
	
	case random
	case newestToOldest
	case oldestToNewest
	case alphabeticalAscending
	case alphabeticalDescending
}
