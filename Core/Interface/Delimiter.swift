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

func removeDelimiters(from text: String, delimiters: [Delimiter]) -> String {
	
	let pairs = delimiters.map { $0.pair }
	var result = ""
	var stack: [Character] = []
	
	for char in text {
		if let open = pairs.first(where: { $0.open == char }) {
			stack.append(open.close)
			continue
		}
		if pairs.contains(where: { $0.close == char }) {
			if stack.last == char {
				stack.removeLast()
			} else if stack.isEmpty {
				result.append(char)
			}
			continue
		}
		if stack.isEmpty { result.append(char) }
	}
	return result
}
