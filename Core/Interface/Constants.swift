//
//  Constants.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/23/26.
//

import CoreFoundation

// MARK: Names will be changed for better ones.

/// An Interface defining every `constant`.
/// `The constants has to be invariant, verify that every (⚠️ critical) value exists.`
enum Constants {
	
	// How many searches are listed.
	static let maxRecents: Int = 200
	
	// ⚠️ Assets catalog -> "deck" (image)
	static let defaultDeckImage: String = "deck"
	
	// Size of the sheet of a new card view.
	static let newCard: CGFloat = 520
	
	// Size of the sheet of a card view.
	static let card: CGFloat = 345
	
	// Size of the sheet of a deck view.
	static let deck: CGFloat = 345
}
