//
//  NewDeckView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 4/21/26.
//

import SwiftUI
import SwiftData
import PhotosUI

/// A view that creates a new Deck.
/// External Dependencies: Deck, Errors, FileImageStorage
struct NewDeckView: View {
	
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.modelContext) private var context
	@Environment(\.dismiss) private var dismiss
	
	let rectangle: RoundedRectangle = RoundedRectangle(cornerRadius: 10, style: .continuous)
	
	@State private var selectedPhotoItem: PhotosPickerItem?
	@State private var selectedImageData: Data?
	@State private var deckName: String = ""
	@State private var showCancelAlert: Bool = false
	@State private var showPhotoPicker: Bool = false
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 30) {
					ZStack {
						rectangle
							.fill(.ultraThinMaterial)
							.overlay {
								if let data = selectedImageData, let uiImage = UIImage(data: data) {
									Image(uiImage: uiImage)
										.resizable()
										.scaledToFill()
								}
							}
							.frame(width: 180, height: 180)
							.clipShape(rectangle)
						Menu {
							Button {
								// Take Photo
							} label: {
								Label("Take Photo", systemImage: "camera")
							}
							Button {
								showPhotoPicker.toggle()
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
						.padding(12)
						.background(Capsule().fill(.thinMaterial))
						.padding()
				}
				.frame(maxWidth: .infinity, alignment: .bottom)
			}
			.toolbar { toolbar }
			.onChange(of: selectedPhotoItem) { _, newItem in
				guard let newItem else { return }
				Task {
					if let data = try? await newItem.loadTransferable(type: Data.self) {
						selectedImageData = data
					}
				}
			}
			.photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
			.alert("New Deck", isPresented: $showCancelAlert) {
				Button("Discard Changes", role: .destructive) { dismiss() }
				Button("Keep Editing", role: .cancel) { }
			} message: {
				Text("Are you sure you want to discard this new deck?")
			}
			.scrollDismissesKeyboard(.interactively)
			.scrollIndicators(.hidden)
		}
	}
}

/// Toolbar.
fileprivate extension NewDeckView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				if !deckName.isEmpty || selectedImageData != nil {
					showCancelAlert.toggle()
				}
			} label: {
				Text("Cancel")
			}
		}
		ToolbarItem(placement: .principal) {
			Text("New Deck")
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				let newDeckName = deckName.trimmingCharacters(in: .whitespacesAndNewlines)
				if newDeckName.isEmpty {
					return showCancelAlert.toggle()
				}
				var image = "deck"
				if let data = selectedImageData, let uiImage = UIImage(data: data) {
					do {
						image = try storage.save(image: uiImage)
					} catch {
						print(Errors.ImageError)
					}
				}
				context.insert(Deck(name: newDeckName, image: image))
				dismiss()
			} label: {
				Label("Done", systemImage: "checkmark")
			}
			.buttonStyle(.borderedProminent)
			.disabled(deckName.isEmpty)
		}
	}
}

#Preview {
	
	let container = try! ModelContainer(for: Deck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
	
	return NewDeckView()
		.modelContainer(container)
		.environment(FileImageStorage())
}
