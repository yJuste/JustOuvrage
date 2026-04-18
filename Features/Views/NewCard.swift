//
//  NewCard.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/18/26.
//

import SwiftUI

struct NewCard: View {
	
	@State private var name: String = ""
	@State private var definition: String = ""
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		NavigationStack {
			VStack(spacing: 50) {
				SplendidField(title: "Name", text: $name)
				SplendidField(title: "Definition", text: $definition)
			}
			.padding()
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						dismiss()
					} label: {
						Text("Cancel")
					}
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						dismiss()
					} label: {
						Label("Done", systemImage: "checkmark")
					}
					.buttonStyle(.borderedProminent)
				}
			}
		}
	}
}

#Preview {
	NewCard()
}
