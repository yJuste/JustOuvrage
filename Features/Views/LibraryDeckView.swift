//
//  LibraryDeckView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/26/26.
//

import SwiftUI

struct LibraryDeckView: View {
	
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.dismiss) private var dismiss
	
	let deck: Deck
	var namespace: Namespace.ID
	
	@State private var showToolbar: Bool = false
	
	var body: some View {
		VStack {
			Image(image: deck.image, storage: storage)
				.resizable()
				.scaledToFill()
				.frame(width: 235, height: 235)
				.aspectRatio(1, contentMode: .fit)
				.clipShape(RoundedRectangle(cornerRadius: 8))
				.shadow(color: .black.opacity(0.3), radius: 20, y: 10)
				.navigationTransition(.zoom(sourceID: deck.id, in: namespace))
			VStack(alignment: .leading, spacing: 6) {
				Text(deck.name)
					.font(.title2)
					.bold()
				Text(deck.depiction)
					.foregroundStyle(.secondary)
			}
			.padding(.top, 12)
			Spacer()
		}
		.frame(maxWidth: .infinity)
		.padding(.top, 25)
		.safeAreaInset(edge: .top) { toolbar }
	}
}

private extension LibraryDeckView {
	
	@ViewBuilder private var toolbar: some View {
		HStack {
			Button {
				dismiss()
			} label: {
				Image(systemName: "chevron.left")
					.font(.system(size: 25, weight: .medium))
					.frame(width: 45, height: 45)
					.glassEffect(.regular.interactive())
			}
			Spacer()
			GlassEffectContainer {
				HStack {
					Button {
						//
					} label: {
						Image(systemName: "ellipsis")
							.font(.system(size: 25, weight: .medium))
							.frame(width: 45, height: 45)
							.glassEffect(.regular.interactive())
					}
				}
			}
		}
		.padding(.horizontal)
		.buttonStyle(.plain)
	}
}
