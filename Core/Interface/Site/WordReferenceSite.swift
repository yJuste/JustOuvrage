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
		
		let expressionEncoded = expression.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? expression
		let link = "https://www.wordreference.com/definition/\(expressionEncoded)"
		
		guard let url = URL(string: link) else { return nil }
		return Destination(url: url)
	}
	
	func link(for expression: String, in language: (Language, Language)) -> Destination? {
		
		let firstLanguageCode = specificLanguage(language: language.0)
		let secondLanguageCode = specificLanguage(language: language.1)
		let expressionEncoded = expression.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? expression
		let link = "https://www.wordreference.com/\(firstLanguageCode)\(secondLanguageCode)/\(expressionEncoded)"
		
		guard let url = URL(string: link) else { return nil }
		return Destination(url: url)
	}
}
