//
//  CleanExpression.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/17/26.
//

import Foundation

func cleanExpression(expression: String) -> [String] {
	
	var results: [String] = []
	var current = ""
	var depth = 0
	
	for char in expression {
		if char == "(" || char == "[" {
			depth += 1
			continue
		}
		if char == ")" || char == "]" {
			depth = max(0, depth - 1)
			continue
		}
		if char == "," && depth == 0 {
			let cleaned = current.unicodeScalars.filter { !$0.properties.isEmojiPresentation }.map(String.init).joined().trimmingCharacters(in: .whitespacesAndNewlines)
			if !cleaned.isEmpty {
				results.append(cleaned)
			}
			current = ""
			continue
		}
		if depth == 0 {
			current.append(char)
		}
	}
	let cleaned = current.unicodeScalars.filter { !$0.properties.isEmojiPresentation }.map(String.init).joined().trimmingCharacters(in: .whitespacesAndNewlines)
	if !cleaned.isEmpty {
		results.append(cleaned)
	}
	return results
}
