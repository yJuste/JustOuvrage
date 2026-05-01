//
//  ForvoSite.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/1/26.
//

import SwiftUI

struct ForvoSite: Site {
	
	func specificLanguage(language: Language) -> String {
		
		switch language {
		case .en_GB: return "en_uk"
		case .en_US: return "en_usa"
		case .es_ES: return "es_es"
		case .fr_CA: return "fr"
		case .fr_FR: return "fr"
		}
	}
	
	func link(for expression: String, in language: Language) -> SiteDestination? {
		
		let language_code = specificLanguage(language: language)
		let expression_encoded = expression.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? expression
		let link = expression.contains(" ")
		? "https://forvo.com/search/\(expression_encoded)/\(language_code)"
		: "https://forvo.com/word/\(expression_encoded)/#\(language_code)"
		
		guard let url = URL(string: link) else { return nil }
		return SiteDestination(url: url)
	}
}
