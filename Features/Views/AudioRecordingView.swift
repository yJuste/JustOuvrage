//
//  AudioRecordingView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/20/26.
//

import SwiftUI
import SwiftData

struct AudioRecordingView: View {
	
	let id: UUID
	let namespace: Namespace.ID
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@State private var verticalOffset: CGFloat = 0
	@State private var selectedCard: Card?
	@State private var showDepiction: Bool = false
	@State private var showCard: Bool = false
	@State private var showRecording: Bool = false
	
	private let session: AudioRecordingSession = Session.unique.audioRecording
	
	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				
				let width = geo.size.width
				let height = geo.size.height
				let isPortrait = height > width
				
				ScrollView {
					VStack {
						Image(.audioRecording)
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
								mainInformation(paddingText: geo.size.height > geo.size.width ? 10 : 100)
									.offset(y: 20)
							}
						LazyVStack(alignment: .leading, spacing: 15) {
							ForEach(cards) { card in
								HStack(spacing: 12) {
									VStack(alignment: .leading, spacing: 5) {
										Text(card.frontEntry)
											.font(.subheadline)
										Text(card.backEntry)
											.font(.subheadline)
											.foregroundStyle(.secondary)
									}
									Spacer()
									Button {
										selectedCard = card
										showCard = false
										showRecording = true
									} label: {
										Image(systemName: "waveform")
											.font(.system(size: 28))
											.padding(12)
											.background(Circle().glassEffect(.clear.interactive()))
									}
									.buttonStyle(.plain)
								}
								.padding()
								.background(RoundedRectangle(cornerRadius: 18).fill(.secondary.opacity(0.2)))
								.onTapGesture {
									selectedCard = card
									showRecording = false
									showCard = true
								}
							}
						}
						.padding()
					}
				}
				.scrollIndicators(.hidden)
				.scrollContentBackground(.hidden)
				.ignoresSafeArea(.container, edges: [.horizontal, .top])
				.sheet(isPresented: $showCard) {
					if let card = selectedCard {
						CardView(card: card)
							.presentationDetents([
								.fraction(Constants.heightOfACard[0]),
								.fraction(Constants.heightOfACard[1])
							])
							.presentationBackgroundInteraction(.enabled)
					}
				}
				.sheet(isPresented: $showRecording) {
					if let card = selectedCard {
						RecordingView(card: card)
							.presentationDetents([
								.fraction(Constants.heightOfARecording[0]),
								.fraction(Constants.heightOfARecording[1])
							])
							.presentationBackgroundInteraction(.enabled)
					}
				}
			}
			.toolbar { toolbar }
			.onScrollGeometryChange(
				for: CGFloat.self,
				of: { $0.contentOffset.y + $0.contentInsets.top },
				action: { _, newValue in
					verticalOffset = -newValue
				}
			)
		}
	}
	
	@ViewBuilder private func mainInformation(paddingText: CGFloat) -> some View {
		VStack(alignment: .center, spacing: 6) {
			Text(session.title)
				.font(.system(size: 50, weight: .black))
				.foregroundStyle(Color(.label))
			Text(session.subtitle)
				.font(.system(size: 20, weight: .semibold))
				.foregroundStyle(Color(.label))
			Text("10 left ⋅ 68%")
				.font(.callout)
				.fontWeight(.medium)
				.padding(.top, 10)
				.foregroundStyle(Color(.label))
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
							.glassEffect(.clear.interactive())
					}
				}
				.font(.system(size: 20, weight: .semibold))
				.foregroundStyle(Color(.label))
			}
			.tint(.primary)
			.padding(.top, 10)
			Text(session.depiction)
				.foregroundStyle(Color(.label))
				.lineLimit(2)
				.multilineTextAlignment(.leading)
				.padding(.horizontal, paddingText)
				.onTapGesture {
					showDepiction.toggle()
				}
				.padding(.horizontal)
				.sheet(isPresented: $showDepiction) {
					ScrollView {
						Text(session.depiction)
							.foregroundStyle(Color(.label))
							.padding(.vertical, 20)
							.padding(.horizontal, 20)
					}
				}
		}
		.foregroundStyle(.white)
		.padding(.bottom, 40)
	}
}

/// Toolbar.
fileprivate extension AudioRecordingView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .principal) {
			Text("Audio Recording")
		}
	}
}

#Preview {
	@Previewable @Namespace var namespace

	let container = try! ModelContainer(
		for: Card.self,
		configurations: ModelConfiguration(isStoredInMemoryOnly: true)
	)

	let context = container.mainContext

	context.insert(Card(
		frontEntry: "hello",
		backEntry: "bonjour",
		frontLanguage: .en_US,
		backLanguage: .fr_FR
	))
	context.insert(Card(
		frontEntry: "hello",
		backEntry: "bonjour",
		frontLanguage: .en_US,
		backLanguage: .fr_FR
	))
	context.insert(Card(
		frontEntry: "hello",
		backEntry: "bonjour",
		frontLanguage: .en_US,
		backLanguage: .fr_FR
	))
	context.insert(Card(
		frontEntry: "hello",
		backEntry: "bonjour",
		frontLanguage: .en_US,
		backLanguage: .fr_FR
	))
	context.insert(Card(
		frontEntry: "hello",
		backEntry: "bonjour",
		frontLanguage: .en_US,
		backLanguage: .fr_FR
	))

	return AudioRecordingView(id: UUID(), namespace: namespace)
		.modelContainer(container)
}
