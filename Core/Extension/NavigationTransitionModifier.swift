//
//  NavigationTransitionModifier.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/9/26.
//

import SwiftUI

extension View {
	
	@ViewBuilder func navigationTransition(id: UUID, namespace: Namespace.ID?) -> some View {
		if let namespace {
			self
				.navigationTransition(.zoom(sourceID: id, in: namespace))
		} else {
			self
		}
	}
}
