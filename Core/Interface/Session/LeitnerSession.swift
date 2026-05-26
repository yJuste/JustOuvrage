//
//  LeitnerSession.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/26/26.
//

import SwiftUI

struct LeitnerSession: SessionService {
	
	let id: UUID = UUID()
	let title: String = "Leitner Box"
	let subtitle: String = "Learn by repetion"
	let depiction: String = "This interface lets you use the Leitner System to learn faster and track all of your progress."
	
	let banner: ImageResource = .leitner
}
