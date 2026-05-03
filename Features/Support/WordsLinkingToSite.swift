//
//  WordsLinkingToSite.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/1/26.
//

import SwiftUI

/// A section that links `words to a site`.
/// External Dependencies: WrapHStack
struct WordsLinkingToSite: View {
	
	let title: String
	let item: [String]
	let action: (String) -> Void
	
	init(_ title: String, item: [String], _ action: @escaping (String) -> Void) {
		self.title = title
		self.item = item
		self.action = action
	}
	
	var body: some View {
		WrapHStack {
			Text(title)
				.font(.caption)
				.foregroundStyle(.accent)
				.padding(.top, 14)
			ForEach(item, id: \.self) { item in
				Button {
					action(item)
				} label: {
					Text(item)
						.font(.system(size: 15, weight: .medium))
						.padding(.vertical, 10)
						.padding(.horizontal, 10)
						.glassEffect(.regular.interactive())
				}
			}
		}
	}
}

#Preview {
	PreviewWrapper()
}

struct PreviewWrapper: View {
	
	let entries: [String] = ["Boeuf", "Agneau", "Canard", "Porc", "Brebis", "Vache"]
	@State private var selected: String?
	
	var body: some View {
		VStack(spacing: 20) {
			WordsLinkingToSite("MySite", item: entries) { value in
				selected = value
			}
			if let selected {
				Text("Selected: \(selected)")
					.font(.headline)
			}
		}
		.padding()
	}
}
