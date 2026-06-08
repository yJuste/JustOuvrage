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
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@State private var selectedPhotoItem: PhotosPickerItem?
	@State private var selectedUIImage: UIImage?
	@State private var deckName: String = ""
	@State private var showCancel: Bool = false
	@State private var showCameraAccess: Bool = false
	@State private var showCameraPicker: Bool = false
	@State private var showPhotoPicker: Bool = false
	@State private var showFilePicker: Bool = false
	
	let rectangle: RoundedRectangle = RoundedRectangle(cornerRadius: 10, style: .continuous)
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 30) {
					ZStack {
						rectangle
							.fill(.ultraThinMaterial)
							.overlay {
								if let uiimage = selectedUIImage {
									Image(uiImage: uiimage)
										.resizable()
										.scaledToFill()
								}
							}
							.frame(width: 180, height: 180)
							.clipShape(rectangle)
						Menu {
							Button {
								Task {
									switch AVCaptureDevice.authorizationStatus(for: .video) {
									case .authorized: showCameraPicker = true
									case .notDetermined:
										if await AVCaptureDevice.requestAccess(for: .video) {
											showCameraPicker.toggle()
										} else {
											showCameraAccess.toggle()
										}
									default:
										showCameraAccess.toggle()
									}
								}
							} label: {
								Label("Take Photo", systemImage: "camera")
							}
							Button {
								showPhotoPicker.toggle()
							} label: {
								Label("Choose Photo", systemImage: "photo.on.rectangle")
							}
							Button {
								showFilePicker.toggle()
							} label: {
								Label("Choose File", systemImage: "folder")
							}
						} label: {
							Image(systemName: "photo")
								.font(.system(size: 19))
								.foregroundStyle(Color.white)
								.frame(width: 65, height: 65)
								.background(Circle().fill(Color.accentColor))
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
			.onChange(of: selectedPhotoItem) { _, newItem in
				guard let newItem else { return }
				Task {
					if let data = try? await newItem.loadTransferable(type: Data.self) {
						selectedUIImage = UIImage(data: data)
					}
				}
			}
			.onDisappear {
				selectedUIImage = nil
				selectedPhotoItem = nil
			}
			.fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.image], allowsMultipleSelection: false) { result in
				switch result {
				case .success(let urls):
					guard let url = urls.first else { return }
					guard url.startAccessingSecurityScopedResource() else { return }
					defer { url.stopAccessingSecurityScopedResource() }
					
					do {
						let data = try Data(contentsOf: url)
						if let image = UIImage(data: data) {
							selectedUIImage = image
						}
					} catch {
						print(Errors.FileManager)
					}
				case .failure: print(Errors.FileManager)
				}
			}
			.sheet(isPresented: $showCameraPicker) {
				CameraCaptureView { image in
					selectedUIImage = image
				}
			}
			.toolbar { toolbar }
			.photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
			.alert("New Deck", isPresented: $showCancel) {
				Button("Discard Changes", role: .destructive) {
					dismiss()
				}
				Button("Keep Editing", role: .cancel) { }
			} message: {
				Text("Are you sure you want to discard this new deck?")
			}
			.alert("Camera Access Required", isPresented: $showCameraAccess) {
				Button("Open Settings") {
					if let url = URL(string: UIApplication.openSettingsURLString) {
						UIApplication.shared.open(url)
					}
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Enable camera access in Settings to use the camera.")
			}
			.scrollDismissesKeyboard(.interactively)
			.scrollIndicators(.hidden)
		}
	}
}

/// Toolbar.
fileprivate extension NewDeckView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		let name = deckName.trimmingCharacters(in: .whitespacesAndNewlines)
		ToolbarItem(placement: .topBarLeading) {
			Button {
				if !name.isEmpty || selectedUIImage != nil {
					return showCancel.toggle()
				}
				dismiss()
			} label: {
				Text("Cancel")
			}
			.foregroundStyle(.primary)
		}
		ToolbarItem(placement: .principal) {
			Text("New Deck")
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				var image = "deck"
				if let uiimage = selectedUIImage {
					do {
						image = try storage.save(image: uiimage)
					} catch {
						print(Errors.Image)
					}
				}
				modelContext.insert(Deck(name: name, image: image, author: Preferences.unique.profileName))
				dismiss()
			} label: {
				Label("Done", systemImage: "checkmark")
			}
			.buttonStyle(.borderedProminent)
			.disabled(name.isEmpty)
		}
	}
}

#Preview {
	
	let container = try! ModelContainer(for: Deck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
	
	return NewDeckView()
		.modelContainer(container)
		.environment(FileImageStorage())
}
