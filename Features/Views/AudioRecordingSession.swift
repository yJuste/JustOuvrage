//
//  AudioRecordingSession.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/19/26.
//

import SwiftUI

struct AudioRecordingSession: View {
	
	let id: UUID
	let namespace: Namespace.ID
	
	@State private var verticalOffset: CGFloat = 0
	
	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				
				let width = geo.size.width
				let height = geo.size.height
				let isPortrait = height > width
				
				ScrollView {
					VStack {
						Image(.yellowflower)
							.resizable()
							.aspectRatio(contentMode: .fill)
							.frame(maxWidth: isPortrait ? width : .infinity)
							.containerRelativeFrame(.vertical) { height, _ in
								isPortrait ? height * 0.8 + max(verticalOffset, 0) * 0.4 : height + max(verticalOffset, 0) * 0.4
							}
							.clipped()
							.navigationTransition(id: id, namespace: namespace)
							.offset(y: verticalOffset > 0 ? -verticalOffset : verticalOffset * 0.2)
							.overlay(alignment: .bottom) {
								mainInformation(paddingText: geo.size.height > geo.size.width ? 30 : 120)
									.offset(y: 20)
							}
						VStack(spacing: 16) {
							ForEach(0..<100, id: \.self) { _ in
								RoundedRectangle(cornerRadius: 20)
									.fill(.gray.opacity(0.2))
									.frame(height: 100)
							}
						}
						.padding()
					}
				}
				.scrollIndicators(.hidden)
				.scrollContentBackground(.hidden)
				.ignoresSafeArea(.container, edges: [.horizontal, .top])
				.onScrollGeometryChange(
					for: CGFloat.self,
					of: { $0.contentOffset.y + $0.contentInsets.top },
					action: { _, newValue in
						verticalOffset = -newValue
					}
				)
			}
		}
	}
	
	@ViewBuilder private func mainInformation(paddingText: CGFloat) -> some View {
		VStack(alignment: .center, spacing: 6) {
			Text("Title")
				.font(.system(size: 50, weight: .black))
			Text("Show subtitle")
				.font(.system(size: 25, weight: .bold))
			Text("Content")
				.font(.callout)
				.fontWeight(.medium)
				.padding(.top, 10)
			GlassEffectContainer {
				HStack(alignment: .center, spacing: 15) {
					Button {
						//
					} label: {
						Label("Record", systemImage: "record.circle")
							.frame(width: 160, height: 50)
							.glassEffect(.regular.tint(.accentColor).interactive())
					}
					Button {
						//
					} label: {
						Image(systemName: "arrow.down")
							.frame(width: 50, height: 50)
							.glassEffect(.regular.tint(.secondary.opacity(0.2)).interactive())
					}
				}
				.font(.system(size: 20, weight: .semibold))
			}
			.tint(.primary)
			.padding(.top, 10)
			Text("Pop star Camila Cabello performs songs from her new album, C, XOXO, and some of her biggest hits at Rock in Rio Lisboa.")
				.foregroundStyle(.secondary)
				.lineLimit(2)
				.multilineTextAlignment(.leading)
				.padding(.horizontal, paddingText)
				.onTapGesture {
					//showDepiction.toggle()
				}
				.padding(.horizontal)
			//				.sheet(isPresented: $showDepiction) {
			//					ScrollView {
			//						Text(deck.depiction)
			//							.padding(.vertical, 20)
			//							.padding(.horizontal, 20)
			//					}
			//				}
		}
		.foregroundStyle(.white)
		.padding(.bottom, 40)
	}
}

#Preview {
	@Previewable @Namespace var namespace
	AudioRecordingSession(id: UUID(), namespace: namespace)
}
