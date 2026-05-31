//
//  TimeTrialSession.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/23/26.
//

import SwiftUI

struct TimeTrialSession: SessionService {
	
	let id: UUID = UUID()
	let title: String = "Time Trial"
	let subtitle: String = "Track your results"
	let depiction: String = """
 This interface lets you track your results from Time Trial Mode.
 
 A small summary in the session header shows how many sessions you've completed along with the average score across all your sessions combined.
 The button in the middle lets you jump directly into Time Trial Mode.
 
 Time Trial results are displayed from the most recent to the oldest.
 
 You'll simply see all the decks you've worked on along with the associated mode.
 The average score is displayed inside a bubble on the right with a color indicating the success level. It also displays the metadata.
 """
	let banner: ImageResource = .timeTrial
	let timeTrialExample: ImageResource = .timeTrialExample
}
