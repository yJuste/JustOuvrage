//
//  SessionBanner.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/19/26.
//

import SwiftUI

struct SessionBanner: View {
	
	let id: UUID
	let namespace: Namespace.ID
	let title: String
	let image: ImageResource
	let action: () -> Void
	
	let rectangle = RoundedRectangle(cornerRadius: 8)
	
	var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				Image(image)
					.resizable()
					.scaledToFill()
				Text(title)
					.bold()
					.padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
					.glassEffect(.clear.interactive())
			}
			.frame(height: 120)
			.clipShape(rectangle)
			.contentShape(rectangle)
			.matchedTransitionSource(id: id, in: namespace)
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	
	@Previewable @Namespace var namespace
	let id: UUID = UUID()
	SessionBanner(id: id, namespace: namespace, title: "Hello Girl", image: .yellowflower) { }
}
