//
//  RemoveDelimiters.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

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
