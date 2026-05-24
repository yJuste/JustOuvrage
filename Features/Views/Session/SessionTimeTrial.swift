//
//  SessionTimeTrial.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/23/26.
//

import SwiftUI
import SwiftData

struct SessionTimeTrial: View {
	
	let id: UUID
	let namespace: Namespace.ID
	
	@Environment(Navigation.self) private var navigation
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \TimeTrial.createdAt, order: .reverse) private var timeTrials: [TimeTrial]
	
	@State private var editMode: EditMode = .inactive
	@State private var selection: Set<UUID> = []
	@State private var showEditMode: Bool = false
	@State private var verticalOffset: CGFloat = 0
	@State private var selectedTimeTrial: TimeTrial?
	@State private var showDepiction: Bool = false
	@State private var showTimeTrial: Bool = false
	@State private var showDownload: Bool = false
	@State private var showSelectedTimeTrial: Bool = false
	
	private let session: TimeTrialSession = Session.unique.timeTrial
	
	private var averagePercentage: Int {
		guard !timeTrials.isEmpty else { return 0 }
		return Int((timeTrials.map(\.success).reduce(0, +) / Double(timeTrials.count) * 100).rounded())
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
							ForEach(timeTrials) { timeTrial in
								let isSelected = selection.contains(timeTrial.id)
								HStack(spacing: 12) {
									if editMode == .active {
										Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
											.font(.title3)
											.foregroundStyle(isSelected ? .accent : .secondary)
									}
									HStack(spacing: 8) {
										VStack(alignment: .leading, spacing: 5) {
											Text(timeTrial.deck?.name ?? "Every Card")
												.font(.subheadline)
											Text(timeTrial.mode.mode)
												.font(.subheadline)
												.foregroundStyle(.secondary)
										}
										Spacer()
										Text("\(timeTrial.cards.count) cards")
											.font(.system(size: 15, weight: .semibold))
										ZStack(alignment: .bottom) {
											Button {
												//
											} label: {
												let score = Int((timeTrial.success * 100).rounded())
												Text("\(score)")
													.font(.system(size: 20, weight: .semibold))
													.foregroundStyle(.background)
													.frame(width: 50, height: 50)
													.background(
														Circle().glassEffect(.clear.tint(score == 100 ? .blue : Color(hue: (Double(score) / 100) * 0.33, saturation: 1, brightness: 1)).interactive())
													)
											}
											.buttonStyle(.plain)
										}
									}
								}
								.padding()
								.background(
									RoundedRectangle(cornerRadius: 18).fill(isSelected ? .accent.opacity(0.3) : .secondary.opacity(0.2))
								)
								.contentShape(Rectangle())
								.onTapGesture {
									if editMode == .active {
										withAnimation(.easeInOut(duration: 0.2)) {
											if isSelected {
												selection.remove(timeTrial.id)
											} else {
												selection.insert(timeTrial.id)
											}
										}
									} else {
										selectedTimeTrial = timeTrial
										showTimeTrial = true
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
			.sheet(isPresented: $showTimeTrial) {
				if let timeTrial = selectedTimeTrial {
					TimeTrialResultView(timeTrial: timeTrial)
						.presentationDetents([
							.fraction(Constants.heightOfATimeTrial[0]),
							.fraction(Constants.heightOfATimeTrial[1])
						])
						.presentationBackgroundInteraction(.enabled)
				}
			}
			.alert("Selected Time Trial Results", isPresented: $showSelectedTimeTrial) {
				Button("Delete", role: .destructive) {
					deleteSelection()
					toggleEditMode()
				}
			} message: {
				Text("Are you sure you want to delete the selection?")
			}
			.alert("Downloading is not implemented yet.", isPresented: $showDownload) {
				Button("OK", role: .cancel) { }
			}
		}
		.environment(\.editMode, $editMode)
	}
	
	@ViewBuilder private func mainInformation(paddingText: CGFloat) -> some View {
		VStack(alignment: .center, spacing: 6) {
			Text(session.title)
				.font(.system(size: 50, weight: .black))
				.foregroundStyle(Color(.label))
			Text(session.subtitle)
				.font(.system(size: 20, weight: .semibold))
				.foregroundStyle(Color(.label))
			Text("\(timeTrials.count) sessions ⋅ \(averagePercentage)% success")
				.font(.callout)
				.fontWeight(.semibold)
				.padding(.top, 10)
				.foregroundStyle(Color(.label))
			GlassEffectContainer {
				HStack(alignment: .center, spacing: 15) {
					Button {
						navigation.selectedTab = .trial
					} label: {
						Label("Session", systemImage: "flag.pattern.checkered.2.crossed")
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
						}
					}
				}
		}
		.foregroundStyle(.white)
		.padding(.bottom, 40)
	}
}

/// Methods of SessionTimeTrialView.
fileprivate extension SessionTimeTrial {
	
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
fileprivate extension SessionTimeTrial {
	
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
			Text("Time Trial")
				.fontWeight(.semibold)
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
	
	let argument = Argument.make(deck: deck1, cards: cards, mode: .chill, directions: [.left], timeInterval: 4.0, order: .alphabeticalAscending, numberOfCards: 30)
	context.insert(deck1)
	context.insert(deck2)
	context.insert(deck3)
	context.insert(TimeTrial(argument: argument, with: 1.0))
	context.insert(TimeTrial(argument: argument, with: 0.1))
	context.insert(TimeTrial(argument: argument, with: 0.843))
	
	return SessionTimeTrial(id: UUID(), namespace: namespace)
		.modelContainer(container)
		.environment(FileImageStorage())
}
