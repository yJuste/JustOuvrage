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
	
	@Environment(Navigation.self) private var navigation
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \TimeTrial.createdAt, order: .reverse) private var timeTrials: [TimeTrial]
	
	@State private var verticalOffset: CGFloat = 0
	@State private var selectedTimeTrial: TimeTrial?
	@State private var editMode: EditMode = .inactive
	@State private var selection: Set<UUID> = []
	@State private var showEditMode: Bool = false
	@State private var showDepiction: Bool = false
	@State private var showTimeTrial: Bool = false
	@State private var showMetaData: Bool = false
	@State private var showDownload: Bool = false
	@State private var showDeleteTimeTrial: Bool = false
	@State private var showSelectedTimeTrial: Bool = false
	
	private let session: LeitnerSession = Session.unique.leitner
	
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
						VStack {
							Text("Not implemented yet.")
						}
						.padding(.top, 40)
					}
				}
				.scrollIndicators(.hidden)
				.scrollContentBackground(.hidden)
				.ignoresSafeArea(.container, edges: [.horizontal, .top])
				.onScrollGeometryChange(for: CGFloat.self, of: { $0.contentOffset.y + $0.contentInsets.top }, action: { _, newValue in verticalOffset = -newValue })
			}
			.toolbar { toolbar }
		}
	}
	
	@ViewBuilder private func mainInformation(paddingText: CGFloat) -> some View {
		
		VStack(alignment: .center, spacing: 6) {
			Text(session.title)
				.font(.system(size: 50, weight: .black))
			Text(session.subtitle)
				.font(.system(size: 20, weight: .semibold))
			Text("10 done ⋅ 23 more")
				.font(.system(size: 16, weight: .semibold))
				.padding(.top, 10)
			GlassEffectContainer {
				HStack(alignment: .center, spacing: 15) {
					Button {
						navigation.selectedTab = .trial
					} label: {
						Label("Session", systemImage: "flag.pattern.checkered.2.crossed")
							.frame(width: 160, height: 50)
							.glassEffect(.regular.tint(.accent).interactive())
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
					showDepiction.toggle()
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
							}
							.padding(.horizontal, 15)
						}
					}
				}
		}
		.padding(.bottom, 40)
	}
}

/// Methods of SessionTimeTrialView.
fileprivate extension SessionLeitnerView {
	
	private func deleteSelection() {
		for timeTrial in timeTrials where selection.contains(timeTrial.id) {
			modelContext.delete(timeTrial)
		}
		withAnimation(.easeInOut(duration: 0.2)) {
			selection.removeAll()
		}
	}
	
	private func toggleEditMode() {
		guard !showEditMode else { return }
		showEditMode.toggle()
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
			showEditMode.toggle()
		}
	}
}

/// Toolbar.
fileprivate extension SessionLeitnerView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			if !selection.isEmpty {
				Button(role: .destructive) {
					showSelectedTimeTrial.toggle()
				} label: {
					Text("Delete (\(selection.count))")
						.foregroundStyle(.red)
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
			Text("Leitner")
		}
	}
}

#Preview {
	
	@Previewable @Namespace var namespace
	
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: Card.self, Deck.self, TimeTrial.self, configurations: config)
	let context = container.mainContext
	let cards: [Card] = [Card(frontEntry: "FrontEntry", backEntry: "BackEntry", frontLanguage: .fr_CA, backLanguage: .en_GB)]
	let deck1 = Deck(name: "Hello", image: "deck")
	let deck2 = Deck(name: "Lucas", image: "deck")
	let deck3 = Deck(name: "All", image: "deck")
	
	let argument = Argument.make(deck: nil, cards: cards, mode: .chill, directions: [.left], timeInterval: 4.0, order: .alphabeticalAscending, numberOfCards: 30)
	context.insert(deck1)
	context.insert(deck2)
	context.insert(deck3)
	context.insert(TimeTrial(argument: argument, with: 1.0))
	context.insert(TimeTrial(argument: argument, with: 0.1))
	context.insert(TimeTrial(argument: argument, with: 0.843))
	
	return SessionLeitnerView(id: UUID(), namespace: namespace)
		.modelContainer(container)
		.environment(FileImageStorage())
		.environment(Navigation())
}
