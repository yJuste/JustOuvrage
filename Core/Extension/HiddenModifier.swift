//
//  HiddenModifier.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/21/26.
//

import SwiftUI

extension View {
	
	/// Extends `.hidden()` to accept a Boolean value.
	///
	/// - Parameters:
	///   - toHide: `true` hides the view, `false` shows it.
	///
	/// - Returns: A `View` if it's false, otherwise nothing.
	///
	/// ## Example
	/// ```swift
	/// Text("Hello")
	///     .hidden(true)
	/// ```
	@ViewBuilder func hidden(_ toHide: Bool) -> some View {
		if toHide {
			self.hidden()
		} else {
			self
		}
	}
}
