//
//  Sort.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/19/26.
//

import SwiftUI
import Foundation

/// Interfaces to sort.
enum SortTrial: Int, CaseIterable {
	
	case random
	case newestToOldest
	case oldestToNewest
	case alphabeticalAscending
	case alphabeticalDescending
}

enum SortCard: String, CaseIterable, Codable, Hashable {
	
	case alphabeticalAscending
	case alphabeticalDescending
	case newestToOldest
	case oldestToNewest
	
	var descriptor: SortDescriptor<Card> {
		switch self {
		case .alphabeticalAscending: return SortDescriptor(\.frontEntry, order: .forward)
		case .alphabeticalDescending: return SortDescriptor(\.frontEntry, order: .reverse)
		case .newestToOldest: return SortDescriptor(\.createdAt, order: .reverse)
		case .oldestToNewest: return SortDescriptor(\.createdAt, order: .forward)
		}
	}
}

enum SortDeck: String, CaseIterable, Codable, Hashable {
	
	case alphabeticalAscending
	case alphabeticalDescending
	case newestToOldest
	case oldestToNewest
	
	var descriptor: SortDescriptor<Deck> {
		switch self {
		case .alphabeticalAscending: return SortDescriptor(\.name, order: .forward)
		case .alphabeticalDescending: return SortDescriptor(\.name, order: .reverse)
		case .newestToOldest: return SortDescriptor(\.createdAt, order: .reverse)
		case .oldestToNewest: return SortDescriptor(\.createdAt, order: .forward)
		}
	}
}
