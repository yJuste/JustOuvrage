//
//  Modifier.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/29/26.
//

import SwiftUI

/// Wrap a modifier.
struct PaddingModifier: ViewModifier {
	
	func body(content: Content) -> some View {
		content
			.padding(.top, 17)
	}
}
