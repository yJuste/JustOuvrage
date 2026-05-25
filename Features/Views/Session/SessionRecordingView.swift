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
	
	@Environment(Recording.self) private var storage
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@State private var verticalOffset: CGFloat = 0
	@State private var selectedCard: Card?
	@State private var editMode: EditMode = .inactive
	@State private var selection: Set<UUID> = []
	@State private var showEditMode: Bool = false
	@State private var showDepiction: Bool = false
	@State private var showCard: Bool = false
	@State private var showRecording: Bool = false
	@State private var showSelectedRecording: Bool = false
	@State private var showDownload: Bool = false
	@State private var showDone: Bool = false
	@State private var showClearRecording: Bool = false
	
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
	
	private var dismissItems: [Binding<Bool>] {
		[$showEditMode, $showDepiction, $showCard, $showRecording]
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
								let isSelected = selection.contains(card.id)
								HStack(spacing: 8) {
									if editMode == .active {
										Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
											.font(.title3)
											.foregroundStyle(isSelected ? .accent : .secondary)
									}
									VStack(alignment: .leading, spacing: 5) {
										Text(card.frontEntry)
										Text(card.backEntry)
											.foregroundStyle(.secondary)
									}
									.font(.subheadline)
									Spacer()
									ZStack(alignment: .bottom) {
										Button {
											selectedCard = card
											dismissItems.showOnly($showRecording)
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
								.background(
									RoundedRectangle(cornerRadius: 18).fill(isSelected ? .accent.opacity(0.3) : .secondary.opacity(0.2))
								)
								.onTapGesture {
									let id = card.id
									if editMode == .active {
										withAnimation(.easeInOut(duration: 0.2)) {
											if isSelected {
												selection.remove(id)
											} else {
												selection.insert(id)
											}
										}
									} else {
										selectedCard = card
										dismissItems.showOnly($showCard)
									}
								}
								.contextMenu {
									Button(role: .destructive) {
										selectedCard = card
										showClearRecording.toggle()
									} label: {
										Label("Clear recordings in the card", systemImage: "trash")
									}
								}
							}
						}
						.padding()
					}
				}
				.scrollIndicators(.hidden)
				.scrollContentBackground(.hidden)
				.ignoresSafeArea(.container, edges: [.horizontal, .top])
				.onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y + $0.contentInsets.top }, action: { _, newValue in verticalOffset = -newValue })
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
			.alert("Clear recordings to the selection?", isPresented: $showSelectedRecording) {
				Button("Clear", role: .destructive) {
					clearSelection()
				}
				Button("Cancel", role: .cancel) { }
			}
			.alert("Clear Recordings", isPresented: $showClearRecording) {
				Button("Clear", role: .destructive) {
					if let card = selectedCard {
						clearRecordings(for: card)
					}
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("This will delete both recordings for this card.")
			}
			.alert("You completed every recording.", isPresented: $showDone) {
				Button("OK", role: .cancel) { }
			}
			.alert("Downloading is not implemented yet.", isPresented: $showDownload) {
				Button("OK", role: .cancel) { }
			}
		}
		.environment(\.editMode, $editMode)
	}
}

/// Methods of SessionRecordingView.
fileprivate extension SessionRecordingView {
	
	@ViewBuilder private func mainInformation(paddingText: CGFloat) -> some View {
		
		VStack(alignment: .center, spacing: 6) {
			Text(session.title)
				.font(.system(size: 50, weight: .black))
			Text(session.subtitle)
				.font(.system(size: 20, weight: .semibold))
			Text("\(audioLeft) left ⋅ \(percentageLeft)% done")
				.font(.system(size: 16, weight: .semibold))
				.padding(.top, 10)
			GlassEffectContainer {
				HStack(alignment: .center, spacing: 15) {
					Button {
						showRecording = false
						if let card = oldestCardWithoutRecording {
							Task {
								try? await Task.sleep(for: .milliseconds(1))
								selectedCard = card
								dismissItems.showOnly($showRecording)
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
			}
			.tint(.primary)
			.padding(.top, 10)
			Text(session.depiction)
				.lineLimit(2)
				.multilineTextAlignment(.leading)
				.padding(.horizontal, paddingText)
				.onTapGesture {
					dismissItems.showOnly($showDepiction)
				}
				.sheet(isPresented: $showDepiction) {
					NavigationStack {
						ScrollView {
							VStack {
								Text(session.title)
									.font(.system(size: 28, weight: .bold))
									.foregroundStyle(.accent)
									.padding(.top, 20)
								Text(session.subtitle)
									.font(.system(size: 20, weight: .bold))
									.padding(.bottom, 20)
								Text(session.depiction)
								Image(session.recordingExample)
									.resizable()
									.scaledToFit()
								Text(session.depiction2)
								Image(session.cardExample)
									.resizable()
									.scaledToFit()
								Text(session.depiction3)
							}
							.padding(.horizontal, 15)
						}
					}
				}
		}
		.padding(.bottom, 40)
	}
}

/// Methods of SessionRecordingView.
fileprivate extension SessionRecordingView {
	
	private func clearSelection() {
		for card in cards where selection.contains(card.id) {
			if let front = card.frontRecording {
				storage.delete(front)
				card.frontRecording = nil
			}
			if let back = card.backRecording {
				storage.delete(back)
				card.backRecording = nil
			}
		}
		withAnimation(.smooth(duration: 0.25)) {
			selection.removeAll()
			editMode = .inactive
		}
	}
	
	private func clearRecordings(for card: Card) {
		if let front = card.frontRecording {
			storage.delete(front)
			card.frontRecording = nil
		}
		if let back = card.backRecording {
			storage.delete(back)
			card.backRecording = nil
		}
	}
	
	private func toggleEditMode() {
		guard !showEditMode else { return }
		dismissItems.toggleOnly($showEditMode)
		withAnimation(.smooth(duration: 0.25)) {
			if editMode == .active {
				editMode = .inactive
				selection.removeAll()
			} else {
				editMode = .active
			}
		}
		Task {
			try? await Task.sleep(for: .milliseconds(250))
			dismissItems.toggleOnly($showEditMode)
		}
	}
}

/// Toolbar.
fileprivate extension SessionRecordingView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			if !selection.isEmpty {
				Button {
					showSelectedRecording.toggle()
				} label: {
					Text("Clear (\(selection.count))")
				}
			}
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				toggleEditMode()
			} label: {
				if editMode.isEditing {
					Text("Cancel")
				} else {
					Text("Select")
				}
			}
		}
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
