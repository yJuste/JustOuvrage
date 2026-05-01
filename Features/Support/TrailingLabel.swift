//
//  TrailingLabel.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/1/26.
//

import SwiftUI

/// Add a custom extension for Label.
struct LabelTrailing<Content: View>: View {
	
	let title: String
	let content: Content
	
	init(title: String, @ViewBuilder content: () -> Content) {
		self.title = title
		self.content = content()
	}
	
	var body: some View {
		VStack(alignment: .leading) {
			Text(title)
				.font(.caption)
				.foregroundStyle(.secondary)
				.frame(maxWidth: .infinity, alignment: .trailing)
			content
		}
	}
}

#Preview {
	
	LabelTrailing(title: "Mount Vesuvius") {
		Text("It is a somma–stratovolcano located on the Gulf of Naples in Campania, Italy.")
	}
}
