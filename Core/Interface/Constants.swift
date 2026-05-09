//
//  Constants.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/23/26.
//

import CoreFoundation

/// An Interface defining every `constant`.
/// `The constants has to be invariant, verify that every (⚠️ critical) value exists.`
enum Constants {
	
	// How many searches are listed.
	static let maxRecentSearches: Int = 200
	
	// ⚠️ Assets catalog -> "deck" (image)
	static let defaultDeckImage: String = "deck"
	
	// Height of the sheet of the new card view.
	static let heightOfANewCard: CGFloat = 0.72
	
	// Height of the sheet of the new card view.
	static let heightOfANewDeck: CGFloat = 0.55
	
	// Height of the sheet of the card view.
	static let heightOfACard: [CGFloat] = [0.31, 0.38]
	
	// Height of the sheet of the deck view.
	static let heightOfADeck: [CGFloat] = [0.47, 1.0]
	
	// Height of a sheet of the draft view.
	static let heightOfADraft: [CGFloat] = [0.315, 0.38]
}
