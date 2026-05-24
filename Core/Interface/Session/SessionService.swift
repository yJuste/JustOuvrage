//
//  SessionService.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/20/26.
//

import SwiftUI

/// A Service that builds links using `...` for website navigation.
protocol SessionService {
	
	var id: UUID { get }
	var title: String { get }
	var subtitle: String { get }
	var depiction: String { get }
	var banner: ImageResource { get }
}
