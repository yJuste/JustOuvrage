//
//  WordReferenceSite.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/4/26.
//

import SwiftUI

struct WordReferenceSite: SiteService {
	
	func specificLanguage(language: Language) -> String {
		switch language {
		case .en_GB: return "en"
		case .en_US: return "en"
		case .es_ES: return "es"
		case .fr_CA: return "fr"
		case .fr_FR: return "fr"
		}
	}
	
	/// Attention, wordReference is an online word traductor. So this function will return the definition.
	func link(for expression: String, in language: Language) -> Destination? {
		guard let url = URL(string: "https://www.wordreference.com/definition/\(expression.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? expression)") else { return nil }
		
		return Destination(url: url)
	}
	
	func link(for expression: String, in languages: (Language, Language)) -> Destination? {
		
		let (first, second) = languages
		let orderedLanguages: (Language, Language)
		
		switch (Self.isSourceLanguage(first), Self.isSourceLanguage(second)) {
		case (false, true):
			orderedLanguages = (second, first)
		case (false, false):
			orderedLanguages = (.en_US, second)
		default:
			orderedLanguages = (first, second)
		}
		
		guard let url = URL(string: "https://www.wordreference.com/\(specificLanguage(language: orderedLanguages.0))\(specificLanguage(language: orderedLanguages.1))/\(expression.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? expression)") else { return nil }
		
		return Destination(url: url)
	}
	
	func link(for expression: String, in language: Language) -> URL {
		link(for: expression, in: language)?.url ?? URL(string: "https://www.wordreference.com")!
	}
	
	func link(for expression: String, in language: (Language, Language)) -> URL {
		link(for: expression, in: language)?.url ?? URL(string: "https://www.wordreference.com")!
	}
}

extension WordReferenceSite {
	
	static func isSourceLanguage(_ language: Language) -> Bool {
		["en", "es", "it"].contains(String(language.rawValue.prefix(2)))
	}
}
