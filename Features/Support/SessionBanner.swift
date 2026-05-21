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
	
	var body: some View {
		Button {
			action()
		} label: {
			ZStack {
				Image(image)
					.resizable()
					.scaledToFill()
					.frame(height: 120)
					.frame(maxWidth: .infinity)
					.matchedTransitionSource(id: id, in: namespace)
				
				Text(title)
					.bold()
					.padding(.horizontal, 12)
					.padding(.vertical, 8)
					.glassEffect(.clear.interactive())
			}
			.clipShape(RoundedRectangle(cornerRadius: 8))
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	
	@Previewable @Namespace var namespace
	let id: UUID = UUID()
	SessionBanner(id: id, namespace: namespace, title: "Hello Girl", image: .yellowflower) {
		//
	}
}
