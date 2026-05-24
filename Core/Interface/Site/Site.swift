//
//  Site.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/5/26.
//

/// An Interface for `Site`
enum Site: CaseIterable {
	
	case forvo
	case wordReference
	case google
	
	static let unique = Sites()
	
	final class Sites {
		
		fileprivate init() {}
		
		lazy var forvo = ForvoSite()
		lazy var wordReference = WordReferenceSite()
		lazy var google = GoogleSite()
	}
}
