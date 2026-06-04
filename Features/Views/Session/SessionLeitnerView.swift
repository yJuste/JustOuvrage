//
//  SessionLeitnerView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/26/26.
//

import SwiftUI
import SwiftData

struct SessionLeitnerView: View {
	
	let id: UUID
	let namespace: Namespace.ID
	
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: [SortDescriptor(\Card.leitnerScore), SortDescriptor(\Card.createdAt)]) private var cards: [Card]
	
	@State private var verticalOffset: CGFloat = 0
	@State private var selectedCard: Card?
	@State private var selectedCardsForSession: [Card]?
	@State private var selectedBoxes: Set<Int> = []
	@State private var editMode: EditMode = .inactive
	@State private var selection: Set<UUID> = []
	@State private var showEditMode: Bool = false
	@State private var showDepiction: Bool = false
	@State private var showCard: Bool = false
	@State private var showSelection: Bool = false
	@State private var showClearLeitner: Bool = false
	@State private var showLearn: Bool = false
	@State private var showNoCards: Bool = false
	@State private var showFinishedSession: Bool = false
	
	private let session: LeitnerSession = Session.unique.leitner
	
	private var pendingCards: [Card] {
		
		let due = Leitner.due(from: cards)
		if selectedBoxes.isEmpty { return due }
		return due.filter { selectedBoxes.contains($0.leitnerScore) }
	}
	
	private var filteredCards: [Card] {
		
		let filtered: [Card]
		if selectedBoxes.isEmpty {
			filtered = cards
		} else {
			filtered = cards.filter { selectedBoxes.contains($0.leitnerScore) }
		}
		return filtered.filter { card in !pendingCards.contains(where: { $0.id == card.id }) }
	}
	
	private var dismissItems: [Binding<Bool>] {
		[$showEditMode, $showDepiction, $showCard, $showLearn]
	}
	
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
					LazyVStack(alignment: .leading, spacing: 15) {
						if !pendingCards.isEmpty {
							Text("Pending")
								.font(.headline)
							ForEach(pendingCards) { card in
								section(card: card)
							}
						}
						if !filteredCards.isEmpty {
							Text("All")
								.font(.headline)
							ForEach(filteredCards) { card in
								section(card: card)
							}
						}
					}
					.id(editMode == .active || showClearLeitner)
					.padding()
				}
				.ignoresSafeArea(.container, edges: [.horizontal, .top])
				.onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y + $0.contentInsets.top }, action: { _, newValue in verticalOffset = -newValue })
			}
			.toolbar { toolbar }
			.navigationDestination(isPresented: $showLearn) {
				if let selection = selectedCardsForSession {
					TimeTrialView(cards: selection, leitner: true)
						.navigationBarBackButtonHidden(true)
						.navigationAllowDismissalGestures(.none)
				}
			}
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
			.alert("Reset leitner scores to the selection?", isPresented: $showSelection) {
				Button("Reset", role: .destructive) {
					resetLeitnerScores()
					toggleEditMode()
				}
				Button("Cancel", role: .cancel) { }
			}
			.alert("Reset leitner score", isPresented: $showClearLeitner) {
				Button("Reset") {
					if let selectedCard {
						Leitner.update(for: selectedCard, score: 1)
					}
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("This will reset the leitner score to 1 for this card.")
			}
			.alert("No cards", isPresented: $showNoCards) {
				Button("OK", role: .cancel) { }
			} message: {
				Text("You can't start the session because there are no cards in Library.")
			}
			.alert("It's done!", isPresented: $showFinishedSession) {
				Button("Nice", role: .cancel) { }
			} message: {
				Text("You have finished the session for today.")
			}
		}
		.environment(\.editMode, $editMode)
	}
}

/// Methods of SessionTimeTrialView.
fileprivate extension SessionLeitnerView {
	
	@ViewBuilder private func section(card: Card) -> some View {
		let isSelected = selection.contains(card.id)
		HStack(spacing: 8) {
			if editMode == .active {
				Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
					.font(.title3)
					.foregroundStyle(isSelected ? Color.accentColor : .secondary)
			}
			VStack(alignment: .leading, spacing: 5) {
				Text(card.frontEntry)
				Text(card.backEntry)
					.foregroundStyle(.secondary)
			}
			.font(.subheadline)
			Spacer()
			Button {
				// Nothing
			} label: {
				Text(card.leitnerScore, format: .number)
					.font(.system(size: 20, weight: .semibold))
					.foregroundStyle(.background)
					.frame(width: 50, height: 50)
					.background(
						Circle().glassEffect(.clear.tint(card.leitnerScore == 1 ? nil : Color(hue: Double(card.leitnerScore - 2) / 5 * 0.75, saturation: 0.9, brightness: 1)).interactive())
					)
			}
			.buttonStyle(.plain)
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 18).fill(isSelected ? Color.accentColor.opacity(0.3) : .secondary.opacity(0.2))
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
			Button {
				selectedCard = card
				showClearLeitner.toggle()
			} label: {
				Label("Clear leitner score", systemImage: "trash")
			}
			.tint(nil)
		}
	}
	
	@ViewBuilder private func mainInformation(paddingText: CGFloat) -> some View {
		
		VStack(alignment: .center, spacing: 6) {
			Text(session.title)
				.font(.system(size: 50, weight: .black))
			Text(session.subtitle)
				.font(.system(size: 20, weight: .semibold))
			let dueCount = Leitner.due(from: cards).count
			let nextTime = Leitner.next(from: cards)
			Text(dueCount == 0 ? "No more ⋅ \(nextTime)" : "\(dueCount) waiting ⋅ \(nextTime)")
				.font(.system(size: 16, weight: .semibold))
				.padding(.top, 10)
			Button {
				guard !cards.isEmpty else { return showNoCards.toggle() }
				let due = Leitner.due(from: cards)
				guard !due.isEmpty else { return showFinishedSession.toggle() }
				selectedCardsForSession = due
				dismissItems.showOnly($showLearn)
			} label: {
				Label("Learn", systemImage: "flag.pattern.checkered.2.crossed")
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
					dismissItems.showOnly($showDepiction)
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
								Image(session.leitnerExample)
									.resizable()
									.scaledToFit()
							}
							.padding(.horizontal, 15)
						}
					}
				}
		}
		.padding(.bottom, 40)
	}
	
	private func resetLeitnerScores() {
		cards.filter { selection.contains($0.id) }.forEach { card in Leitner.update(for: card, score: 1) }
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
fileprivate extension SessionLeitnerView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			if !selection.isEmpty {
				Button {
					showSelection.toggle()
				} label: {
					Text("Reset (\(selection.count))")
				}
				.foregroundStyle(.primary)
			}
		}
		ToolbarItem(placement: .principal) {
			Text("Leitner")
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
			.foregroundStyle(.primary)
		}
		ToolbarSpacer(placement: .topBarTrailing)
		ToolbarItem(placement: .topBarTrailing) {
			Menu {
				ForEach(1..<8, id: \.self) { box in
					let contain = selectedBoxes.contains(box)
					Button {
						if contain {
							selectedBoxes.remove(box)
						} else {
							selectedBoxes.insert(box)
						}
					} label: {
						Label {
							Text("Box \(box)")
						} icon: {
							Image(systemName: "checkmark")
								.hidden(!contain)
						}
					}
				}
			} label: {
				Label("Boxes", systemImage: "line.3.horizontal.decrease.circle")
			}
			.tint(nil)
		}
	}
}

#Preview {
	
	@Previewable @Namespace var namespace
	
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: Card.self, Deck.self, TimeTrial.self, configurations: config)
	let context = container.mainContext
	let _: [Card] = [Card(frontEntry: "FrontEntry", backEntry: "BackEntry", frontLanguage: .fr_CA, backLanguage: .en_GB, author: "yJuste")]
	let deck1 = Deck(name: "Hello", image: "deck", author: "yJuste")
	let deck2 = Deck(name: "Lucas", image: "deck", author: "yJuste")
	let deck3 = Deck(name: "All", image: "deck", author: "yJuste")
	
	context.insert(deck1)
	context.insert(deck2)
	context.insert(deck3)
	
	return SessionLeitnerView(id: UUID(), namespace: namespace)
		.modelContainer(container)
		.environment(FileImageStorage())
}
