//
//  Language.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

/// An interface to categorize the language codes.
/// [ISO 639-1] + \_ + [ISO 3166]
/// An interface to link a language code with its associated flag.
/// An interface to link a language code with a language.
enum Language: String, Codable, CaseIterable {
	
	case en_GB
	case en_US
	case es_ES
	case fr_CA
	case fr_FR
}

extension Language {
	
	var language: String {
		switch self {
		case .en_GB: return "English - United Kingdom"
		case .en_US: return "English - United States of America"
		case .es_ES: return "Español - España"
		case .fr_CA: return "Français - Canada"
		case .fr_FR: return "Français - France"
		}
	}
	
	var flagAsset: String {
		switch self {
		case .en_GB: return "Flags/gb"
		case .en_US: return "Flags/us"
		case .es_ES: return "Flags/es"
		case .fr_CA: return "Flags/ca"
		case .fr_FR: return "Flags/fr"
		}
	}
}
