//
//  NewCardView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/19/26.
//

import SwiftUI
import SwiftData

/// A view that can creates a new Card.
/// External Dependencies: Card, FlagPicker, SplendidField, Preferences
struct NewCardView: View {
	
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@Bindable private var preferences: Preferences = .unique
	@FocusState private var focusField: FocusField?
	@State private var frontEntry: String = ""
	@State private var backEntry: String = ""
	@State private var frontLanguage: Language = Preferences.unique.frontLanguage
	@State private var backLanguage: Language = Preferences.unique.backLanguage
	@State private var showFrontLanguage: Bool = false
	@State private var showBackLanguage: Bool = false
	@State private var showAddedCard: Bool = false
	@State private var showAddedBanner: Bool = false
	@State private var showCancel: Bool = false
	
	var body: some View {
		NavigationStack {
			ScrollViewReader { proxy in
				ScrollView {
					Spacer(minLength: 100)
					VStack(spacing: 50) {
						HStack(spacing: 40) {
							Button {
								showFrontLanguage.toggle()
							} label: {
								Image(frontLanguage.flagAsset)
									.resizable()
									.scaledToFill()
									.frame(width: 60, height: 60)
									.clipShape(Circle())
							}
							.popover(isPresented: $showFrontLanguage) {
								FlagPicker(selected: $frontLanguage)
									.padding(25)
									.presentationCompactAdaptation(.none)
							}
							Button {
								withAnimation(.spring(response: 0.3)) {
									(frontLanguage, backLanguage) = (backLanguage, frontLanguage)
								}
							} label: {
								Image(systemName: "arrow.left.arrow.right")
							}
							.buttonStyle(.plain)
							.padding()
							.glassEffect(.regular.interactive())
							Button {
								showBackLanguage.toggle()
							} label: {
								Image(backLanguage.flagAsset)
									.resizable()
									.scaledToFill()
									.frame(width: 60, height: 60)
									.clipShape(Circle())
							}
							.popover(isPresented: $showBackLanguage) {
								FlagPicker(selected: $backLanguage)
									.padding(20)
									.presentationCompactAdaptation(.none)
							}
						}
						VStack(spacing: 50) {
							SplendidField(title: "Front Entry", text: $frontEntry)
								.id(FocusField.front)
								.focused($focusField, equals: .front)
							SplendidField(title: "Back Entry", text: $backEntry)
								.id(FocusField.back)
								.focused($focusField, equals: .back)
						}
					}
					.padding(30)
				}
				.scrollDismissesKeyboard(.interactively)
				.scrollIndicators(.hidden)
				.onChange(of: focusField) {
					guard let field = focusField else { return }
					Task { @MainActor in
						try? await Task.sleep(for: .milliseconds(250))
						withAnimation {
							proxy.scrollTo(field, anchor: .top)
						}
					}
				}
			}
			.toolbar { toolbar }
			.onSubmit {
				if focusField == .front {
					focusField = .back
				} else {
					addCard(
						front: frontEntry.trimmingCharacters(in: .whitespacesAndNewlines),
						back: backEntry.trimmingCharacters(in: .whitespacesAndNewlines)
					)
				}
			}
			.onTapGesture {
				focusField = nil
			}
			.overlay(alignment: .top) {
				if showAddedBanner {
					Label("Added", systemImage: "checkmark.circle.fill")
						.environment(\.layoutDirection, .rightToLeft)
						.font(.subheadline.weight(.medium))
						.padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
						.background(.regularMaterial)
						.clipShape(Capsule())
						.transition(.move(edge: .top).combined(with: .opacity))
				}
			}
			.alert("Missing Information", isPresented: $showAddedCard) {
				Button("Got it", role: .cancel) { }
			} message: {
				Text("Please fill in both sides before saving.")
			}
			.alert("New Card", isPresented: $showCancel) {
				Button("Discard Changes", role: .destructive) {
					frontEntry = ""
					backEntry = ""
					focusField = nil
					dismiss()
				}
				Button("Keep Editing", role: .cancel) { }
			} message: {
				Text("Are you sure you want to discard this new card?")
			}
		}
	}
}

/// Methods of NewCardView.
fileprivate extension NewCardView {
	
	@MainActor private func showAdded() async {
		withAnimation(.snappy) {
			showAddedBanner.toggle()
		}
		try? await Task.sleep(for: .seconds(1.5))
		withAnimation(.snappy) {
			showAddedBanner.toggle()
		}
	}
	
	private func addCard(front: String, back: String) {
		if front.isEmpty || back.isEmpty {
			showAddedCard.toggle()
		} else {
			modelContext.insert(Card(frontEntry: front, backEntry: back, frontLanguage: frontLanguage, backLanguage: backLanguage))
			preferences.frontLanguage = frontLanguage
			preferences.backLanguage = backLanguage
			frontEntry = ""
			backEntry = ""
			focusField = .front
			Task { await showAdded() }
			dismiss()
		}
	}
}

/// Toolbar.
fileprivate extension NewCardView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		let frontEntry = frontEntry.trimmingCharacters(in: .whitespacesAndNewlines)
		let backEntry = backEntry.trimmingCharacters(in: .whitespacesAndNewlines)
		ToolbarItem(placement: .topBarLeading) {
			Button {
				if frontEntry.isEmpty && backEntry.isEmpty {
					dismiss()
				} else {
					showCancel.toggle()
				}
			} label: {
				Text("Cancel")
			}
		}
		ToolbarItem(placement: .principal) {
			if ((cards.first?.frontEntry) != nil) && ((cards.first?.backEntry) != nil) {
				Text("\(cards.first?.frontEntry ?? "Front Entry") : \(cards.first?.backEntry ?? "Back Entry")")
					.font(.caption)
			} else {
				Text("Here is your last entries.")
					.font(.caption)
			}
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				addCard(front: frontEntry, back: backEntry)
			} label: {
				Label("Done", systemImage: "checkmark")
			}
			.buttonStyle(.borderedProminent)
			.disabled(frontEntry.isEmpty || backEntry.isEmpty)
		}
	}
}

#Preview {
	NewCardView()
}
