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
/// External Dependencies:
struct NewDeckView: View {
	
	@Environment(\.modelContext) var context
	@Environment(\.dismiss) var dismiss
	
	@State private var storage = FileImageStorage()
	@State private var selectedPhotoItem: PhotosPickerItem?
	@State private var selectedImageData: Data?
	@State private var showCancelAlert: Bool = false
	@State private var deckName: String = ""
	@State private var savedImageURL: String?
	
	@State private var showPhotoPicker: Bool = false
	
	var body: some View {
		
		NavigationStack {
			ScrollViewReader { proxy in
				ScrollView {
					VStack(spacing: 30) {
						ZStack {
							RoundedRectangle(cornerRadius: 10, style: .continuous)
								.fill(.ultraThinMaterial)
								.overlay {
									if let data = selectedImageData,
									   let uiImage = UIImage(data: data) {
										Image(uiImage: uiImage)
											.resizable()
											.scaledToFill()
									}
								}
								.frame(width: 180, height: 180)
								.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
							.lineLimit(1)
							.padding(12)
							.background(Capsule().fill(.thinMaterial))
							.padding()
					}
					.frame(maxWidth: .infinity, alignment: .bottom)
					.toolbar {
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
								var image = "deck"
								if let data = selectedImageData, let uiImage = UIImage(data: data) {
									do {
										image = try storage.save(image: uiImage)
									} catch {
										print(Errors.ImageError)
									}
								}
								context.insert(Deck(name: deckName, image: image))
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
			.photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
			.onChange(of: selectedPhotoItem) { _, newItem in
				guard let newItem else { return }
				Task {
					if let data = try? await newItem.loadTransferable(type: Data.self) {
						selectedImageData = data
					}
				}
			}
			.alert("New Deck", isPresented: $showCancelAlert) {
				Button("Discard Changes", role: .destructive) { dismiss() }
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
