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
	
	@State private var frontEntry: String = ""
	@State private var backEntry: String = ""
	@State private var frontLanguage: Language = .en_US
	@State private var backLanguage: Language = .en_US
	
	@State private var showFront: Bool = false
	@State private var showBack: Bool = false
	@State private var showAlert: Bool = false
	
	@Environment(\.modelContext) var context
	@Environment(\.dismiss) var dismiss
	
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
					SplendidField(title: "Back Entry", text: $backEntry)
				}
			}
			.padding(40)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) {
					Button("Cancel") {
						dismiss()
					}
				}
				ToolbarItem(placement: .topBarTrailing) {
					Button {
						if frontEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
							|| backEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
							showAlert.toggle()
						}
						context.insert(Card(frontEntry: frontEntry, backEntry: backEntry, frontLanguage: frontLanguage, backLanguage: backLanguage))
						dismiss()
					} label: {
						Label("Done", systemImage: "checkmark")
					}
					.buttonStyle(.borderedProminent)
				}
			}
		}
		.alert("Error", isPresented: $showAlert) {
			Button("OK", role: .cancel) { }
		} message: {
			Text("Entries cannot be empty.")
		}
	}
}

#Preview {
	NewCardView()
}
