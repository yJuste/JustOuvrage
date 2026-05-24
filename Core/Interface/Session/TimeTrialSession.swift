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
	let depiction: String = "This interface lets you track your results from the Time Trial Mode."
	
	let banner: ImageResource = .timeTrial
}
