//
//  Destination.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/4/26.
//

import Foundation

/// An Interface for creating a unique `destination` for a url.
struct	Destination: Identifiable {
	
	let id = UUID()
	let url: URL
}
