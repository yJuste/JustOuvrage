//
//  NewCardView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/19/26.
//

import SwiftUI
import SwiftData

/// A view that can creates a new Card.
/// External Dependencies: Card, FlagPicker, SplendidField
struct NewCardView: View {
	
	@State private var preferences = Preferences.unique
	
	@Environment(\.modelContext) var context
	@Environment(\.dismiss) var dismiss
	
	@Query(sort: \Card.createdAt, order: .reverse) private var cards: [Card]
	
	@State private var frontEntry: String = ""
	@State private var backEntry: String = ""
	@State private var frontLanguage: Language = Preferences.unique.frontLanguage
	@State private var backLanguage: Language = Preferences.unique.backLanguage
	
	@FocusState private var focusField: FocusField?
	@State private var showFront: Bool = false
	@State private var showBack: Bool = false
	@State private var showAddedCard: Bool = false
	@State private var showAddedBanner: Bool = false
	@State private var showCancelAlert: Bool = false
	
	var body: some View {
		NavigationStack {
			ScrollViewReader { proxy in
				ScrollView {
					Spacer(minLength: 100)
					VStack(spacing: 50) {
						HStack(spacing: 40) {
							Button {
								showFront.toggle()
							} label: {
								Image(frontLanguage.flagAsset)
									.resizable()
									.scaledToFill()
									.frame(width: 60, height: 60)
									.clipShape(Circle())
							}
							.popover(isPresented: $showFront) {
								FlagPicker(selected: $frontLanguage)
									.padding(25)
									.presentationCompactAdaptation(.none)
							}
							Image(systemName: "arrow.left.arrow.right")
							Button {
								showBack.toggle()
							} label: {
								Image(backLanguage.flagAsset)
									.resizable()
									.scaledToFill()
									.frame(width: 60, height: 60)
									.clipShape(Circle())
							}
							.popover(isPresented: $showBack) {
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
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button {
								let newFrontEntry = frontEntry.trimmingCharacters(in: .whitespacesAndNewlines)
								let newBackEntry = backEntry.trimmingCharacters(in: .whitespacesAndNewlines)
								if newFrontEntry.isEmpty && newBackEntry.isEmpty {
									dismiss()
								} else {
									showCancelAlert.toggle()
								}
							} label: {
								Text("Cancel")
							}
						}
						ToolbarItem(placement: .principal) {
							Text("\(cards.first?.frontEntry ?? "Front Entry") : \(cards.first?.backEntry ?? "Back Entry")")
								.font(.caption)
						}
						ToolbarItem(placement: .topBarTrailing) {
							Button {
								addCard()
							} label: {
								Label("Done", systemImage: "checkmark")
							}
							.buttonStyle(.borderedProminent)
							.disabled(frontEntry.isEmpty || backEntry.isEmpty)
						}
					}
					.onSubmit {
						if focusField == .front {
							focusField = .back
						} else {
							addCard()
						}
					}
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
			.alert("Missing Information", isPresented: $showAddedCard) {
				Button("Got it", role: .cancel) { }
			} message: {
				Text("Please fill in both sides before saving.")
			}
			.alert("New Card", isPresented: $showCancelAlert) {
				Button("Discard Changes", role: .destructive) {
					frontEntry = ""
					backEntry = ""
					focusField = nil
					dismiss()
				}
				Button("Keep Editing", role: .cancel) { }
			} message: {
				Text("Are you sure you want to discard this new deck?")
			}
			.onTapGesture {
				focusField = nil
			}
			.overlay(alignment: .top) {
				if showAddedBanner {
					HStack(spacing: 6) {
						Text("Ajouté")
						Image(systemName: "checkmark.circle.fill")
					}
					.font(.subheadline.weight(.medium))
					.padding(.horizontal, 14)
					.padding(.vertical, 10)
					.background(.thinMaterial)
					.clipShape(Capsule())
					.padding(.top, 0)
					.transition(.move(edge: .top).combined(with: .opacity))
				}
			}
		}
	}
	
	func showAdded() {
		withAnimation(.snappy) {
			showAddedBanner = true
		}
		
		Task {
			try? await Task.sleep(for: .seconds(2))
			
			await MainActor.run {
				withAnimation(.snappy) {
					showAddedBanner = false
				}
			}
		}
	}
	
	func addCard() {
		
		let newFrontEntry = frontEntry.trimmingCharacters(in: .whitespacesAndNewlines)
		let newBackEntry = backEntry.trimmingCharacters(in: .whitespacesAndNewlines)
		if newFrontEntry.isEmpty || newBackEntry.isEmpty {
			return showAddedCard.toggle()
		}
		context.insert(Card(frontEntry: newFrontEntry, backEntry: newBackEntry, frontLanguage: frontLanguage, backLanguage: backLanguage))
		
		preferences.frontLanguage = frontLanguage
		preferences.backLanguage = backLanguage
		frontEntry = ""
		backEntry = ""
		focusField = .front
		showAdded()
		dismiss()
	}
}

/// An interface to use to toggle a focusState.
extension NewCardView {
	
	enum FocusField: Hashable {
		
		case front
		case back
	}
}

#Preview {
	NewCardView()
}
