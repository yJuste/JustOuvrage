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
	@State private var showAlert: Bool = false
	
	var body: some View {
		NavigationStack {
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
						.focused($focusField, equals: .front)
					SplendidField(title: "Back Entry", text: $backEntry)
						.focused($focusField, equals: .back)
				}
			}
			.padding(40)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button {
						frontEntry = ""
						backEntry = ""
						focusField = nil
						dismiss()
					} label: {
						Text("Cancel")
					}
				}
				ToolbarItem(placement: .principal) {
					Text("\(cards.first?.frontEntry ?? "Front Entry") : \(cards.first?.backEntry ?? "Back Entry")")
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						addCard()
					} label: {
						Label("Done", systemImage: "checkmark")
					}
					.buttonStyle(.borderedProminent)
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
		.alert("Missing Information", isPresented: $showAlert) {
			Button("Got it", role: .cancel) { }
		} message: {
			Text("Please fill in both sides before saving.")
		}
		.onTapGesture {
			focusField = nil
		}
	}
	
	func addCard() {
		
		let newFrontEntry = frontEntry.trimmingCharacters(in: .whitespacesAndNewlines)
		let newBackEntry = backEntry.trimmingCharacters(in: .whitespacesAndNewlines)
		if newFrontEntry.isEmpty || newBackEntry.isEmpty {
			return showAlert.toggle()
		}
		context.insert(Card(frontEntry: newFrontEntry, backEntry: newBackEntry, frontLanguage: frontLanguage, backLanguage: backLanguage))
		
		preferences.frontLanguage = frontLanguage
		preferences.backLanguage = backLanguage
		frontEntry = ""
		backEntry = ""
		focusField = .front
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
