//
//  GoogleSite.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/4/26.
//

//https://www.google.com/search?q=drip+definition&hl=en&gl=us
//https://www.google.com/search?q=こんにちは+定義&hl=ja&gl=jp
import SwiftUI

struct GoogleSite: SiteService {
	
	func specificLanguage(language: Language) -> String {
		
		switch language {
		case .en_GB: return "definition_en_gb"
		case .en_US: return "definition_en_us"
		case .es_ES: return "definición_es_es"
		case .fr_CA: return "definition_fr_ca"
		case .fr_FR: return "definition_fr_fr"
		}
	}
	
	func link(for expression: String, in language: Language) -> Destination? {
		
		let languageCode = specificLanguage(language: language).components(separatedBy: "_")
		let expressionEncoded = expression.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? expression
		let link = "https://google.com/search?q=\(expressionEncoded)+\(languageCode[0])&hl=\(languageCode[1])&gl=\(languageCode[2])"
		
		guard let url = URL(string: link) else { return nil }
		return Destination(url: url)
	}
	
	func link(for expression: String, in language: (Language, Language)) -> Destination? {
		return link(for: expression, in: language.0)
	}
}
