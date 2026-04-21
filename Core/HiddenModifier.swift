//
//  HiddenModifier.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/21/26.
//

import SwiftUI

/// Add an extension for the modifier .hidden()
/// .hidden() can now take a Bool parameter -> ``.hidden( Bool )``
extension View {
	
	@ViewBuilder func hidden(_ toHide: Bool) -> some View {
		if toHide {
			self.hidden()
		} else {
			self
		}
	}
}
