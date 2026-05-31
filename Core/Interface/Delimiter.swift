//
//  Delimiter.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

enum Delimiter {
	
	case parentheses
	case brackets
	case braces
	case angle
	
	var pair: (open: Character, close: Character) {
		switch self {
		case .parentheses: return ("(", ")")
		case .brackets: return ("[", "]")
		case .braces: return ("{", "}")
		case .angle: return ("<", ">")
		}
	}
}
