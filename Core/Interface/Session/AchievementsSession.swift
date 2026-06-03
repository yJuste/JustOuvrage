//
//  AchievementsSession.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

import SwiftUI

struct AchievementsSession: SessionService {
	
	let id: UUID = UUID()
	let title: String = "Achievements"
	let subtitle: String = "Earn and unlock rewards"
	let depiction: String = """
 Earn trophies and medals by reaching your goals and improving your performance.
 """
	let banner: ImageResource = .achievements
	let leitnerExample: ImageResource = .achievements
}
