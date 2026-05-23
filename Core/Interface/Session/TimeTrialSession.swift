//
//  TimeTrialSession.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/23/26.
//

import SwiftUI

struct TimeTrialSession: SessionService {
	
	var title: String = "Time Trial"
	var subtitle: String = "Track your time trial results"
	var depiction: String = ""
	
	var recordingExample = Image(.audioRecordingExample)
	var cardExample = Image(.cardExample)
}
