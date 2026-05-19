//
//  Session.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/18/26.
//

import SwiftData
import Foundation

/// A Model for a  ``Session``.
/// External Dependencies: Deck, Mode
@Model final class Session {
	
	@Attribute(.unique) var id: UUID
	var deck: Deck?
	var mode: Mode
	var success: Double
	
	private(set) var createdAt: Date
	
	init(in deck: Deck?, using mode: Mode, with success: Double) {
		self.id = UUID()
		self.deck = deck
		self.mode = mode
		self.success = success
		self.createdAt = .now
	}
}
