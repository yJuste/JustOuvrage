//
//  Card.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/15/26.
//

import SwiftData
import Foundation

/// A Model for a Card.
/// External Dependencies: Language
@Model class Card: Identifiable {

	var id = UUID()
	var name: String
	var definition: String
	var pronunciation: String = ""
	var context: String = "This card is super cool."
	var language: Language
	var leitnerScore: Int = 1

	private(set) var creationDate: Date = Date()
	private(set) var cardNumber: Int = 1

	init(name: String, definition: String, language: Language = .en_US) {
		self.name = name
		self.definition = definition
		self.language = language
	}
}
