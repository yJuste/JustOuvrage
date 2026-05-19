//
//  Sort.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/19/26.
//

/// Interfaces to sort.
enum SortTrial: Int, CaseIterable {
	
	case random
	case newestToOldest
	case oldestToNewest
	case alphabeticalAscending
	case alphabeticalDescending
}

enum SortCard {
	
	case alphabeticalAscending
	case alphabeticalDescending
	case alphabeticalLanguageAscending
	case alphabeticalLanguageDescending
	case newestToOldest
	case oldestToNewest
}

enum SortDeck {
	
	case alphabeticalAscending
	case alphabeticalDescending
	case newestToOldest
	case oldestToNewest
}
