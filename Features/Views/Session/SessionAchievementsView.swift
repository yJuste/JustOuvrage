//
//  SessionAchievementsView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/31/26.
//

import SwiftUI
import SwiftData

struct SessionAchievementsView: View {
	
	let id: UUID
	let namespace: Namespace.ID
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query private var cards: [Card]
	@Query private var decks: [Deck]
	@Query private var timeTrials: [TimeTrial]
	
	@Bindable private var preferences: Preferences = .unique
	@State private var verticalOffset: CGFloat = 0
	@State private var selectedAchievement: Achievements?
	@State private var showDepiction: Bool = false
	@State private var showAchievement: Bool = false
	
	private let session: AchievementsSession = Session.unique.achievements
	
	var body: some View {
		NavigationStack {
			let context = AchievementContext(cards: cards, decks: decks, timeTrials: timeTrials, cleanupDate: preferences.lastCleanup, profileName: preferences.profileName)
			GeometryReader { geo in
				
				let width = geo.size.width
				let height = geo.size.height
				let isPortrait = height > width
				let padding = isPortrait ? 15.0 : 55.0
				
				ScrollView {
					Image(session.banner)
						.resizable()
						.scaledToFill()
						.aspectRatio(contentMode: .fill)
						.frame(maxWidth: isPortrait ? width : .infinity)
						.containerRelativeFrame(.vertical) { height, _ in
							isPortrait ? height * 0.8 + max(verticalOffset, 0) * 0.4 : height + max(verticalOffset, 0) * 0.4
						}
						.clipped()
						.navigationTransition(id: id, namespace: namespace)
						.offset(y: verticalOffset > 0 ? -verticalOffset : 0)
						.overlay(alignment: .bottom) {
							mainInformation(paddingText: height > width ? 10 : 100, context: context)
								.offset(y: 20)
						}
					LazyVStack(alignment: .leading, spacing: 15) {
						ForEach(Achievements.allCases) { achievement in
							AchievementView(achievement: achievement, context: context) {
								selectedAchievement = achievement
								showAchievement = true
							}
						}
					}
					.padding(EdgeInsets(top: 15, leading: padding, bottom: 15, trailing: padding))
					.sheet(isPresented: $showAchievement) {
						if let achievement = selectedAchievement {
							AchievementMetaDataView(achievement: achievement, context: context)
								.presentationDetents([
									.fraction(Constants.heightOfAMetaData[0]),
									.fraction(Constants.heightOfAMetaData[1])
								])
								.presentationBackgroundInteraction(.enabled)
						}
					}
				}
				.ignoresSafeArea(.container, edges: [.horizontal, .top])
				.onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y + $0.contentInsets.top }, action: { _, newValue in verticalOffset = -newValue })
			}
			.toolbar { toolbar }
		}
	}
}

/// Methods of SessionRecordingView.
fileprivate extension SessionAchievementsView {
	
	@ViewBuilder private func mainInformation(paddingText: CGFloat, context: AchievementContext) -> some View {
		let all = Achievements.allCases
		VStack(alignment: .center, spacing: 6) {
			Text(session.title)
				.font(.system(size: 50, weight: .black))
			Text(session.subtitle)
				.font(.system(size: 20, weight: .semibold))
			Text("\(all.filter { $0.isUnlocked(in: context) }.count)/\(all.count) reached")
				.font(.system(size: 16, weight: .semibold))
				.padding(.top, 10)
			Button {
				guard let (achievement, _) = (all.map { achievement in (achievement, achievement.pourcentage(in: context)) }.filter { $0.1 < 1.0 }.max(by: { $0.1 < $1.1 })) else { return }
				selectedAchievement = achievement
				showAchievement = true
			} label: {
				Label("Achieve", systemImage: "flag.2.crossed")
					.font(.system(size: 20, weight: .semibold))
					.tint(.primary)
					.frame(width: 200, height: 50)
					.glassEffect(.regular.tint(Color.accentColor).interactive())
			}
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
