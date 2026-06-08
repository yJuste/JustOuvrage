//
//  SessionTimeTrialView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/24/26.
//

import SwiftUI
import SwiftData

struct SessionTimeTrialView: View {
	
	let id: UUID
	let namespace: Namespace.ID
	
	@Environment(Navigation.self) private var navigation
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query private var timeTrials: [TimeTrial]
	
	@State private var sort: SortTimeTrial = .newestToOldest
	@State private var verticalOffset: CGFloat = 0
	@State private var selectedTimeTrial: TimeTrial?
	@State private var editMode: EditMode = .inactive
	@State private var selection: Set<UUID> = []
	@State private var showEditMode: Bool = false
	@State private var showDepiction: Bool = false
	@State private var showTimeTrial: Bool = false
	@State private var showMetaData: Bool = false
	@State private var showDeleteTimeTrial: Bool = false
	@State private var showSelectedTimeTrial: Bool = false
	
	private let session: TimeTrialSession = Session.unique.timeTrial
	
	private var sortedTimeTrials: [TimeTrial] {
		timeTrials.sorted { lhs, rhs in
			if let result = sort.compare(lhs, rhs) {
				return result == .orderedAscending
			}
			return false
		}
	}
	
	private var averagePercentage: Double {
		timeTrials.isEmpty ? 0 : timeTrials.map(\.success).reduce(0, +) / Double(timeTrials.count)
	}
	
	private var dismissItems: [Binding<Bool>] {
		[$showEditMode, $showDepiction, $showTimeTrial, $showMetaData]
	}
	
	var body: some View {
		NavigationStack {
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
							mainInformation(paddingText: height > width ? 10 : 100)
								.offset(y: 20)
						}
					LazyVStack(alignment: .leading, spacing: 15) {
						ForEach(sortedTimeTrials) { timeTrial in
							let isSelected = selection.contains(timeTrial.id)
							HStack(spacing: 12) {
								if editMode == .active {
									Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
										.font(.title3)
										.foregroundStyle(isSelected ? Color.accentColor : .secondary)
								}
								HStack(spacing: 8) {
									VStack(alignment: .leading, spacing: 5) {
										Text(timeTrial.deck?.name ?? "Every Card")
										Text(timeTrial.mode.mode)
											.foregroundStyle(.secondary)
									}
									.font(.subheadline)
									Spacer()
									Text("\(timeTrial.cards.count) cards")
										.font(.system(size: 15, weight: .semibold))
									Button {
										selectedTimeTrial = timeTrial
										dismissItems.showOnly($showMetaData)
									} label: {
										let score = Int((timeTrial.success * 100).rounded())
										Text(score, format: .number)
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
							.padding()
							.background(
								RoundedRectangle(cornerRadius: 18).fill(isSelected ? Color.accentColor.opacity(0.3) : .secondary.opacity(0.2))
							)
							.contentShape(Rectangle())
							.onTapGesture {
								let id = timeTrial.id
								if editMode == .active {
									withAnimation(.easeInOut(duration: 0.2)) {
										if isSelected {
											selection.remove(id)
										} else {
											selection.insert(id)
										}
									}
								} else {
									selectedTimeTrial = timeTrial
									dismissItems.showOnly($showTimeTrial)
								}
							}
							.contextMenu {
								Button(role: .destructive) {
									selectedTimeTrial = timeTrial
									showDeleteTimeTrial.toggle()
								} label: {
									Label("Delete from Time Trial", systemImage: "trash")
								}
								.tint(nil)
							}
						}
					}
					.padding(EdgeInsets(top: 15, leading: padding, bottom: 15, trailing: padding))
				}
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
			.sheet(isPresented: $showMetaData) {
				if let timeTrial = selectedTimeTrial {
					TimeTrialMetaDataView(timeTrial: timeTrial)
						.presentationDetents([
							.fraction(Constants.heightOfAMetaData[0]),
							.fraction(Constants.heightOfAMetaData[1])
						])
						.presentationBackgroundInteraction(.enabled)
				}
			}
			.alert("Are you sure you want to delete this result from Time Trial?", isPresented: $showDeleteTimeTrial) {
				Button("Delete", role: .destructive) {
					if let timeTrial = selectedTimeTrial {
						modelContext.delete(timeTrial)
					}
				}
				Button("Cancel", role: .cancel) { }
			}
			.alert("Selected Time Trial Results", isPresented: $showSelectedTimeTrial) {
				Button("Delete", role: .destructive) {
					deleteSelection()
					toggleEditMode()
				}
			} message: {
				Text("Are you sure you want to delete the selection?")
			}
		}
		.environment(\.editMode, $editMode)
	}
}

/// Methods of SessionTimeTrialView.
fileprivate extension SessionTimeTrialView {
	
	@ViewBuilder private func mainInformation(paddingText: CGFloat) -> some View {
		
		VStack(alignment: .center, spacing: 6) {
			Text(session.title)
				.font(.system(size: 50, weight: .black))
			Text(session.subtitle)
				.font(.system(size: 20, weight: .semibold))
			Text("\(timeTrials.count) sessions ⋅ \(averagePercentage, format: .percent.precision(.fractionLength(0)))")
				.font(.system(size: 16, weight: .semibold))
				.padding(.top, 10)
			Button {
				dismissItems.setAll(to: false)
				navigation.selectedTab = .trial
			} label: {
				Label("Session", systemImage: "flag.pattern.checkered.2.crossed")
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
								Image(session.timeTrialExample)
									.resizable()
									.scaledToFill()
									.clipShape(RoundedRectangle(cornerRadius: 15))
							}
							.padding(.horizontal, 15)
						}
					}
				}
		}
		.padding(.bottom, 40)
	}
	
	private func deleteSelection() {
		for timeTrial in timeTrials where selection.contains(timeTrial.id) {
			modelContext.delete(timeTrial)
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
fileprivate extension SessionTimeTrialView {
	
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
		ToolbarItem(placement: .principal) {
			Text("Time Trial")
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
				Button {
					sort = sort == .newestToOldest ? .oldestToNewest : .newestToOldest
				} label: {
					let newest = sort == .newestToOldest
					Label("Date", systemImage: newest ? "text.line.first.and.arrowtriangle.forward" : "text.line.last.and.arrowtriangle.forward")
					Text(newest ? "Newest to Oldest" : "Oldest to Newest")
				}
				Button {
					sort = sort == .alphabeticalAscending ? .alphabeticalDescending : .alphabeticalAscending
				} label: {
					let ascending = sort == .alphabeticalAscending
					Label("Name", systemImage: ascending ? "text.line.first.and.arrowtriangle.forward" : "text.line.last.and.arrowtriangle.forward")
					Text(ascending ? "Ascending" : "Descending")
				}
			} label: {
				Label("Options", systemImage: "line.3.horizontal.decrease")
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
	let cards: [Card] = [Card(frontEntry: "FrontEntry", backEntry: "BackEntry", frontLanguage: .fr_CA, backLanguage: .en_GB, author: "yJuste")]
	let deck1 = Deck(name: "Hello", image: "deck", author: "yJuste")
	let deck2 = Deck(name: "Lucas", image: "deck", author: "yJuste")
	let deck3 = Deck(name: "All", image: "deck", author: "yJuste")
	
	let argument = Argument.make(deck: nil, cards: cards, side: .front, mode: .chill, directions: [.left], timeInterval: 4.0, order: .alphabeticalAscending, numberOfCards: 30)
	context.insert(deck1)
	context.insert(deck2)
	context.insert(deck3)
	context.insert(TimeTrial(argument: argument, with: 1.0))
	context.insert(TimeTrial(argument: argument, with: 0.1))
	context.insert(TimeTrial(argument: argument, with: 0.843))
	
	return SessionTimeTrialView(id: UUID(), namespace: namespace)
		.modelContainer(container)
		.environment(FileImageStorage())
		.environment(Navigation())
}
