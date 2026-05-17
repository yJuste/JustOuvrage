//
//  Timer.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/17/26.
//

import Foundation

struct Timer: Identifiable {
	
	enum Status {
		
		case idle
		case active
		case paused
		case finished
	}
	
	let id: UUID
	var duration: TimeInterval
	var status: Status = .idle
	
	var startDate: Date?
	var pauseDate: Date?
}
