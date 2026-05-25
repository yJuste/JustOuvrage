//
//  LeadingLabel.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/25/26.
//

import SwiftUI

struct LeadingLabel<Content: View>: View {
	
	let title: String
	let content: () -> Content
	
	var body: some View {
		HStack {
			Text(title)
				.foregroundStyle(.secondary)
			Spacer()
			content()
		}
	}
}


#Preview {
	
	LeadingLabel(title: "Mount Vesuvius") {
		Text("It is a somma–stratovolcano located on the Gulf of Naples in Campania, Italy.")
	}
}
