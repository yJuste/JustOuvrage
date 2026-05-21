//
//  AudioRecordingSession.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/20/26.
//

import SwiftUI

struct AudioRecordingSession: SessionService {
	
	var title: String = "Audio Recording"
	var subtitle: String = "Record your own pronunciation"
	var depiction: String = "This service provides you an interface to record your own pronunciation for your cards. An icon will be added to the right of the card and be clicked to listen to your recording."
	
	func action() -> String {
		return "audio"
	}
}
