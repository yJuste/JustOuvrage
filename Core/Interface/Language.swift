//
//  Language.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

import Foundation

/// An interface to categorize the `language codes`.
/// [ISO 639-1] + \_ + [ISO 3166]
enum Language: String, Codable, CaseIterable, Comparable {
	
	case en_GB
	case en_US
	case es_ES
	case fr_CA
	case fr_FR
	
	/// An extension that link a language code with a language.
	var language: String {
		switch self {
		case .en_GB: return "English - United Kingdom"
		case .en_US: return "English - United States of America"
		case .es_ES: return "Español - España"
		case .fr_CA: return "Français - Canada"
		case .fr_FR: return "Français - France"
		}
	}
	
	/// An extension that link a language code with its associated flag.
	var flagAsset: String {
		switch self {
		case .en_GB: return "Flags/gb"
		case .en_US: return "Flags/us"
		case .es_ES: return "Flags/es"
		case .fr_CA: return "Flags/ca"
		case .fr_FR: return "Flags/fr"
		}
	}
	
	/// Comparable.
	static func < (lhs: Language, rhs: Language) -> Bool {
		lhs.language < rhs.language
	}
	
	/// Code.
	var code: String {
		language.components(separatedBy: " - ").first ?? language
	}
	
	static var codes: [String] {
		Array(Set(allCases.map(\.code))).sorted()
	}
}
