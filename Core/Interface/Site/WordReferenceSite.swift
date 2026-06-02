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
	
	func link(for expression: String, in language: (Language, Language)) -> Destination? {
		guard let url = URL(string: "https://www.wordreference.com/\(specificLanguage(language: language.0))\(specificLanguage(language: language.1))/\(expression.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? expression)") else { return nil }
		
		return Destination(url: url)
	}
	
	func link(for expression: String, in language: Language) -> URL {
		link(for: expression, in: language)?.url ?? URL(string: "https://www.wordreference.com")!
	}
	
	func link(for expression: String, in language: (Language, Language)) -> URL {
		link(for: expression, in: language)?.url ?? URL(string: "https://www.wordreference.com")!
	}
}
