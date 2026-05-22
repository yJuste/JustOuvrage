//
//  Mode.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/19/26.
//

/// Interface that represents available modes.
enum Mode: Int, Codable, CaseIterable {
	
	case chill
	case standard
	case death
	case custom
	
	var mode: String {
		switch self {
		case .chill: return "Chill"
		case .standard: return "Standard"
		case .death: return "Death"
		case .custom: return "Custom"
		}
	}
}
