//
//  Language.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/16/26.
//

/// An interface to categorize the languages.
/// [ISO 639-1] + \_ + [ISO 3166]
enum Language: String, Codable, CaseIterable {

	case en_US
	case en_GB
	case fr_FR
	case fr_CA
	case es_ES
}
