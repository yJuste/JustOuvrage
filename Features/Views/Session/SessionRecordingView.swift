//
//  SessionRecordingView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/23/26.
//

import SwiftUI
import SwiftData

struct SessionRecordingView: View {
	
	let id: UUID
	let namespace: Namespace.ID
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@State private var verticalOffset: CGFloat = 0
	@State private var selectedCard: Card?
	@State private var selection: Set<Card> = []
	@State private var editMode: EditMode = .inactive
	@State private var showDepiction: Bool = false
	@State private var showCard: Bool = false
	@State private var showRecording: Bool = false
	@State private var showDownload: Bool = false
	@State private var showDone: Bool = false
	
	private let session: RecordingSession = Session.unique.audioRecording
	
	private var audioLeft: Int {
		cards.reduce(0) { result, card in
			result + (card.frontRecording == nil ? 1 : 0) + (card.backRecording == nil ? 1 : 0)
		}
	}
	
	private var percentageLeft: Int {
		let total = cards.count * 2
		guard total > 0 else { return 0 }
		let completed = cards.reduce(into: 0) { result, card in
			if card.frontRecording != nil {
				result += 1
			}
			if card.backRecording != nil {
				result += 1
			}
		}
		return Int((Double(completed) / Double(total)) * 100)
	}
	
	private var oldestCardWithoutRecording: Card? {
		cards.last(where: { $0.frontRecording == nil || $0.backRecording == nil })
	}
	
	var body: some View {
		NavigationStack {
			GeometryReader { geo in
				
				let width = geo.size.width
				let height = geo.size.height
				let isPortrait = height > width
				
				ScrollView {
					VStack {
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
								mainInformation(paddingText: geo.size.height > geo.size.width ? 10 : 100)
									.offset(y: 20)
							}
						LazyVStack(alignment: .leading, spacing: 15) {
							ForEach(cards) { card in
								HStack(spacing: 8) {
									VStack(alignment: .leading, spacing: 5) {
										Text(card.frontEntry)
											.font(.subheadline)
										Text(card.backEntry)
											.font(.subheadline)
											.foregroundStyle(.secondary)
									}
									Spacer()
									ZStack(alignment: .bottom) {
										Button {
											selectedCard = card
											showCard = false
											showRecording = true
										} label: {
											Image(systemName: "waveform")
												.font(.system(size: 28))
												.padding(12)
												.background(Circle().glassEffect(.clear.tint(card.frontRecording != nil && card.backRecording != nil ? .green : card.frontRecording != nil || card.backRecording != nil ? .orange : .clear).interactive()))
										}
										.buttonStyle(.plain)
										HStack(spacing: 0) {
											if card.frontRecording != nil {
												Image(systemName: "circle.fill")
											}
											if card.backRecording != nil {
												Image(systemName: "circle.fill")
											}
										}
										.font(.caption2)
										.offset(y: 5)
									}
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
				.onScrollGeometryChange(
					for: CGFloat.self,
					of: { $0.contentOffset.y + $0.contentInsets.top },
					action: { _, newValue in
						verticalOffset = -newValue
					}
				)
			}
			.toolbar { toolbar }
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
			.alert("You completed every recording.", isPresented: $showDone) {
				Button("OK", role: .cancel) { }
			}
			.alert("Downloading is not implemented yet.", isPresented: $showDownload) {
				Button("OK", role: .cancel) { }
			}
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
			Text("\(audioLeft) left ⋅ \(percentageLeft)% done")
				.font(.callout)
				.fontWeight(.semibold)
				.padding(.top, 10)
				.foregroundStyle(Color(.label))
			GlassEffectContainer {
				HStack(alignment: .center, spacing: 15) {
					Button {
						showRecording = false
						if let card = oldestCardWithoutRecording {
							Task {
								try? await Task.sleep(for: .milliseconds(1))
								selectedCard = card
								showCard = false
								showRecording = true
							}
						} else {
							showDone.toggle()
						}
					} label: {
						Label("Record", systemImage: "record.circle")
							.frame(width: 160, height: 50)
							.glassEffect(.regular.tint(.accentColor).interactive())
					}
					Button {
						showDownload.toggle()
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
					NavigationStack {
						ScrollView {
							Text(session.title)
								.font(.title)
								.bold()
								.foregroundStyle(.accent)
								.padding(.horizontal, 20)
								.padding(.top, 20)
							Text(session.subtitle)
								.font(.title3)
								.bold()
								.foregroundStyle(Color(.label).opacity(0.7))
								.padding(.horizontal, 20)
								.padding(.bottom, 20)
							Text(session.depiction)
								.foregroundStyle(Color(.label))
								.padding(.horizontal, 20)
							Image(session.recordingExample)
							Text(session.depiction2)
								.foregroundStyle(Color(.label))
								.padding(.horizontal, 20)
							Image(session.cardExample)
							Text(session.depiction3)
								.foregroundStyle(Color(.label))
								.padding(.horizontal, 20)
						}
					}
				}
		}
		.foregroundStyle(.white)
		.padding(.bottom, 40)
	}
}

/// Toolbar.
fileprivate extension SessionRecordingView {
	
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

	return SessionRecordingView(id: UUID(), namespace: namespace)
		.modelContainer(container)
}
