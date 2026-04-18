//
//  Recording.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

import Foundation

/// A built-in recorder.
struct Recording: Identifiable, Equatable {
	
	let id = UUID()
	let url: URL
	let date: Date
	let sequence: Int
}
