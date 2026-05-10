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
}

/// Height of Sheets.
extension Constants {
	
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

/// Icons.
extension Constants {
	
	// Icon for the new card view.
	static let newCardIcon: String = "plus.square.fill.on.square.fill"
	
	// Icon for the new Deck view.
	static let newDeckIcon: String = "rectangle.stack.badge.plus"
	
	// Icon for the menu of adding cards/decks.
	static let addSectionIcon: String = "square.fill.text.grid.1x2"
	
	// Icon for the card section in Library.
	static let cardsSectionIcon: String = "square.3.layers.3d"
	
	// Icon for the deck section in Library.
	static let decksSectionIcon: String = "rectangle.stack.badge.play.fill"
	
	// Icon for the settings view.
	static let settingsIcon: String = "gear"
	
	// Icon for swiping flags in new card view.
	static let swipeFlagIcon: String = "arrow.left.arrow.right"
	
	// Icon for the new card view in tab view.
	static let newTabIcon: String = "plus.rectangle.portrait"
	
	// Icon for the trial view in tab view.
	static let trialTabIcon: String = "flag.pattern.checkered.2.crossed"
	
	// Icon for the record view in tab view.
	static let recordTabIcon: String = "rectangle.dashed.badge.record"
	
	// Icon for the library view in tab view.
	static let libraryTabIcon: String = "rectangle.stack.fill"
	
	// Icon for each search in search view.
	static let magnifyingGlassIcon: String = "magnifyingglass"
	
	// Icon the exact match in search view.
	static let primaryMagnifyingGlassIcon: String = "magnifyingglass.circle.fill"
}
