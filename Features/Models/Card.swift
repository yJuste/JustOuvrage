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
@Model final class Card {

	var name: String
	var definition: String
	var language: Language
	var pronunciation: String = ""
	var context: String = ""

	private(set) var leitnerScore: Int = 1
	private(set) var creationDate: Date = Date()

	init(name: String, definition: String, language: Language = .en_US) {
		self.name = name
		self.definition = definition
		self.language = language
	}
}
