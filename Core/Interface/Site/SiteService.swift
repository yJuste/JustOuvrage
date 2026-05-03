//
//  SiteService.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/1/26.
//

import Foundation

// MARK: SiteDestination will be Destination in future patches.

/// A Service that builds links using `SpecificLanguage, Link` for website navigation.
protocol Site {
	
	func specificLanguage(language: Language) -> String
	func link(for expression: String, in language: Language) -> SiteDestination?
}

/// A dependency for creating a unique `site destination` for a url.
struct SiteDestination: Identifiable {
	
	let id = UUID()
	let url: URL
}
