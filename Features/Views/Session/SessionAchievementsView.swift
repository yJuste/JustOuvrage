//
//  SessionAchievementsView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

import SwiftUI

struct SessionAchievementsView: View {
	
	let id: UUID
	let namespace: Namespace.ID
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var verticalOffset: CGFloat = 0
	@State private var showDepiction: Bool = false
	@State private var showDownload: Bool = false
	
	private let session: AchievementsSession = Session.unique.achievements
	
	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				
				let width = geo.size.width
				let height = geo.size.height
				let isPortrait = height > width
				
				ScrollView {
					Image(session.banner)
						.resizable()
						.aspectRatio(contentMode: .fill)
						.frame(maxWidth: isPortrait ? width : .infinity)
						.containerRelativeFrame(.vertical) { height, _ in
							isPortrait ? height * 0.8 + max(verticalOffset, 0) * 0.4 : height + max(verticalOffset, 0) * 0.4
						}
						.clipped()
						.navigationTransition(id: id, namespace: namespace)
						.offset(y: verticalOffset > 0 ? -verticalOffset : 0)
						.overlay(alignment: .bottom) {
							mainInformation(paddingText: height > width ? 10 : 100)
								.offset(y: 20)
						}
				}
				.ignoresSafeArea(.container, edges: [.horizontal, .top])
				.onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y + $0.contentInsets.top }, action: { _, newValue in verticalOffset = -newValue })
			}
			.toolbar { toolbar }
			.alert("Downloading is not implemented yet.", isPresented: $showDownload) {
				Button("OK", role: .cancel) { }
			}
		}
		//.environment(\.editMode, $editMode)
	}
}

/// Methods of SessionRecordingView.
fileprivate extension SessionAchievementsView {
	
	@ViewBuilder private func mainInformation(paddingText: CGFloat) -> some View {
		
		VStack(alignment: .center, spacing: 6) {
			Text(session.title)
				.font(.system(size: 50, weight: .black))
			Text(session.subtitle)
				.font(.system(size: 20, weight: .semibold))
			Text("...........")
				.font(.system(size: 16, weight: .semibold))
				.padding(.top, 10)
			GlassEffectContainer {
				HStack(alignment: .center, spacing: 15) {
					Button {
						//
					} label: {
						Label("Achieve", systemImage: "flag.2.crossed")
							.frame(width: 160, height: 50)
							.glassEffect(.regular.tint(Color.accentColor).interactive())
					}
					Button {
						//
					} label: {
						Image(systemName: "arrow.down")
							.frame(width: 50, height: 50)
							.glassEffect(.clear.interactive())
					}
				}
				.font(.system(size: 20, weight: .semibold))
			}
			.tint(.primary)
			.padding(.top, 10)
			Text(session.depiction)
				.lineLimit(2)
				.multilineTextAlignment(.leading)
				.padding(.horizontal, paddingText)
				.onTapGesture {
					showDepiction.toggle()
				}
				.sheet(isPresented: $showDepiction) {
					NavigationStack {
						ScrollView {
							VStack {
								Text(session.title)
									.font(.system(size: 28, weight: .bold))
									.foregroundStyle(Color.accentColor)
									.padding(.top, 20)
								Text(session.subtitle)
									.font(.system(size: 20, weight: .bold))
									.padding(.bottom, 20)
								Text(session.depiction)
							}
							.padding(.horizontal, 15)
						}
					}
				}
		}
		.padding(.bottom, 40)
	}
}

/// Toolbar.
fileprivate extension SessionAchievementsView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .principal) {
			Text("Achievements")
		}
	}
}
