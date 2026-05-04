//
//  SiteService.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/1/26.
//

import Foundation

/// A Service that builds links using `SpecificLanguage, Link` for website navigation.
protocol SiteService {
	
	func specificLanguage(language: Language) -> String
	func link(for expression: String, in language: Language) -> Destination?
	func link(for expression: String, in language: (Language, Language)) -> Destination?
}
