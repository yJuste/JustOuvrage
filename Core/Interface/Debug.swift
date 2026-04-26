//
//  Debug.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/21/26.
//

import os

/// An Interface to debug.
enum Debug {
	
	private static let logger = Logger(subsystem: "com.yJuste.JustOuvrage.app", category: "debug")
	
	static func print(level: OSLogType = .debug, card: Card) {
#if DEBUG
		logger.log(level: level, """
   FrontEntry: \(card.frontEntry, privacy: .public)
   BackEntry: \(card.backEntry, privacy: .public)
   FrontLanguage: \(card.frontLanguage.rawValue, privacy: .public)
   BackLanguage: \(card.backLanguage.rawValue, privacy: .public)
   LeitnerScore: \(card.leitnerScore, privacy: .public)
   Date created: \(card.createdAt, privacy: .public)
   LastViewedAt: \(String(describing: (card.lastViewedAt)), privacy: .public)
   """)
#endif
	}
}
