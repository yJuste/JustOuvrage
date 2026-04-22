//
//  NewDeckView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/21/26.
//

import SwiftUI
import SwiftData

// Use FileManager, PhotoPicker

/// A view that creates a new Deck.
/// External Dependencies:
struct NewDeckView: View {
	
	@Environment(\.modelContext) var context
	@Environment(\.dismiss) var dismiss
	
	@State private var showCancelAlert: Bool = false
	@State private var deckName: String = ""
	
	var body: some View {
		
		NavigationStack {
			ScrollViewReader { proxy in
				ScrollView {
					VStack(spacing: 30) {
						ZStack {
							RoundedRectangle(cornerRadius: 10, style: .continuous)
								.fill(.ultraThinMaterial)
								.frame(width: 180, height: 180)
							Menu {
								Button {
									// Open Camera
								} label: {
									Label("Take Photo", systemImage: "camera")
								}
								Button {
									// Open Library
								} label: {
									Label("Choose Photo", systemImage: "photo.on.rectangle")
								}
								Button {
									// Open Files
								} label: {
									Label("Choose File", systemImage: "folder")
								}
							} label: {
								Button {
									//
								} label: {
									Image(systemName: "photo")
										.font(.custom("picture icon", size: 19))
										.foregroundStyle(Color.white)
										.frame(width: 65, height: 65)
										.background(Circle().fill(Color.accentColor))
								}
							}
						}
						TextField("Deck Name", text: $deckName)
							.bold()
							.multilineTextAlignment(.center)
							.lineLimit(1)
							.padding(12)
							.background(Capsule().fill(.thinMaterial))
							.padding()
					}
					.frame(maxWidth: .infinity, alignment: .bottom)
					.toolbar {
						ToolbarItem(placement: .topBarLeading) {
							Button {
								if !deckName.isEmpty {
									showCancelAlert.toggle()
								}
								dismiss()
							} label: {
								Text("Cancel")
							}
						}
						ToolbarItem(placement: .principal) {
							Text("New Deck")
						}
						ToolbarItem(placement: .topBarTrailing) {
							Button {
								dismiss()
							} label: {
								Label("Done", systemImage: "checkmark")
							}
							.buttonStyle(.borderedProminent)
							.disabled(deckName.isEmpty)
						}
					}
				}
				.scrollDismissesKeyboard(.interactively)
				.scrollIndicators(.hidden)
			}
			.alert("New Deck", isPresented: $showCancelAlert) {
				Button("Discard Changes", role: .destructive) { }
				Button("Keep Editing", role: .cancel) { }
			} message: {
				Text("Are you sure you want to discard this new deck?")
			}
		}
	}
}

#Preview {
	NewDeckView()
}
