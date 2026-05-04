//
//  ForvoSite.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/1/26.
//

import SwiftUI

struct ForvoSite: SiteService {
	
	func specificLanguage(language: Language) -> String {
		
		switch language {
		case .en_GB: return "en_uk"
		case .en_US: return "en_usa"
		case .es_ES: return "es_es"
		case .fr_CA: return "fr"
		case .fr_FR: return "fr"
		}
	}
	
	func link(for expression: String, in language: Language) -> Destination? {
		
		let languageCode = specificLanguage(language: language)
		let expressionEncoded = expression.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? expression
		let link = expression.contains(" ")
		? "https://forvo.com/search/\(expressionEncoded)/\(languageCode)"
		: "https://forvo.com/word/\(expressionEncoded)/#\(languageCode)"
		
		guard let url = URL(string: link) else { return nil }
		return Destination(url: url)
	}
	
	func link(for expression: String, in language: (Language, Language)) -> Destination? {
		link(for: expression, in: language.0)
	}
}
