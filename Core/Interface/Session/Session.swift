//
//  Session.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/19/26.
//

/// Creates a Session Interface. (Session can creates multiple service for JustOuvrage)
enum Session: CaseIterable {
	
	case audioRecording
	case timeTrial
	case leitner
	
	static let unique = Sessions()
	
	final class Sessions {
		
		fileprivate init() {}
		
		lazy var audioRecording = RecordingSession()
		lazy var timeTrial = TimeTrialSession()
		lazy var leitner = LeitnerSession()
	}
}
