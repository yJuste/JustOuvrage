//
//  CharacterExtension.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/7/26.
//

extension Character {
	var isEmoji: Bool { unicodeScalars.contains { $0.properties.isEmojiPresentation || $0.properties.isEmoji } }
}
