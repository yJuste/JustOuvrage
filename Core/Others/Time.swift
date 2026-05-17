//
//  Time.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/17/26.
//

import SwiftUI

@Observable final class Time {
	
	var timers: [Timer]
	
	init(timers: [Timer]) {
		self.timers = timers
	}
	
	/// Methods.
	
	func add(duration: TimeInterval) {
		timers.append(Timer(id: UUID(), duration: duration))
	}
	
	func add(duration: TimeInterval, repetition: UInt) {
		for _ in 0..<repetition {
			timers.append(Timer(id: UUID(), duration: duration))
		}
	}
	
	func remove(timer id: UUID) {
		timers.removeAll { $0.id == id }
	}
	
	func remove() {
		timers.removeAll()
	}
	
	func set(status: Timer.Status, for id: UUID) {
		for i in timers.indices {
			if timers[i].id == id {
				timers[i].status = status
			}
		}
	}
	
	/// Start.
	
	func start() {
		for i in timers.indices {
			timers[i].status = .active
		}
	}
	
	func pause() {
		for i in timers.indices {
			guard timers[i].status == .active else { continue }
			timers[i].status = .paused
		}
	}
	
	func stop() {
		for i in timers.indices {
			timers[i].status = .idle
		}
	}
	
	func stop(only status: Timer.Status) {
		for i in timers.indices {
			guard timers[i].status == status else { continue }
			timers[i].status = .idle
		}
	}
	
	func stop(only status: [Timer.Status]) {
		for i in timers.indices {
			if status.contains(timers[i].status) { continue }
			timers[i].status = .idle
		}
	}
	
	func status(_ status: Timer.Status, for id: UUID) -> Bool {
		timers.first{ $0.id == id }?.status == status
	}
}
