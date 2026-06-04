//
//  EditDeckView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/22/26.
//

import SwiftUI
import SwiftData
import PhotosUI

// MARK: Add take photos and search from files.

struct EditDeckView: View {
	
	let title: String
	let deck: Deck
	let onSave: (Deck) -> Void
	
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@FocusState private var focusField: FocusField?
	@State private var name: String = ""
	@State private var depiction: String = ""
	@State private var selectedPhotoItem: PhotosPickerItem?
	@State private var selectedUIImage: UIImage?
	@State private var showCancel: Bool = false
	@State private var showPhotoPicker: Bool = false
	@State private var showClearImage: Bool = false
	@State private var isChangedImage: Bool = false
	@State private var isInitialImage: Bool = false
	
	private let rectangle: RoundedRectangle = RoundedRectangle(cornerRadius: 10, style: .continuous)
	
	init(title: String, deck: Deck, onSave: @escaping (Deck) -> Void = { _ in }) {
		self.title = title
		self.deck = deck
		self.onSave = onSave
		_name = State(initialValue: deck.name)
		_depiction = State(initialValue: deck.depiction)
	}
	
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
									.font(.system(size: 19))
									.foregroundStyle(Color.white)
									.frame(width: 65, height: 65)
									.background(Circle().fill(Color.accentColor))
							}
						}
					}
					VStack(spacing: 20) {
						TextField("Deck Name", text: $name)
							.bold()
							.padding(12)
							.multilineTextAlignment(.center)
							.background(Capsule().fill(.thinMaterial))
						ZStack(alignment: .top) {
							TextEditor(text: $depiction)
								.scrollContentBackground(.hidden)
								.padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
								.frame(minHeight: 120)
								.background(.thinMaterial)
								.clipShape(RoundedRectangle(cornerRadius: 16))
							if depiction.isEmpty {
								Text("Description")
									.bold()
									.foregroundColor(.secondary.opacity(0.5))
									.padding(.vertical, 25)
							}
						}
						HStack {
							Spacer()
							Button {
								showClearImage.toggle()
							} label: {
								Label("Clear Image", systemImage: "trash")
									.foregroundStyle(Color(.label))
									.frame(width: 170, height: 55)
									.glassEffect(.clear.interactive())
							}
						}
					}
					.padding(.horizontal)
				}
				.frame(maxWidth: .infinity, alignment: .bottom)
				.padding(.bottom, 80)
			}
			.onChange(of: selectedPhotoItem) { _, newItem in
				guard let newItem else { return }
				Task {
					if let data = try? await newItem.loadTransferable(type: Data.self) {
						selectedUIImage = UIImage(data: data)
						isChangedImage = true
					}
				}
			}
			.onAppear {
				if selectedUIImage == nil {
					if let image = try? storage.load(image: deck.image) {
						selectedUIImage = image
						isInitialImage = false
					} else {
						selectedUIImage = UIImage(named: Constants.defaultDeckImage)
						isInitialImage = true
					}
				}
			}
			.onDisappear {
				selectedUIImage = nil
				selectedPhotoItem = nil
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
			.alert("Clear Image", isPresented: $showClearImage) {
				Button("Clear", role: .destructive) {
					selectedUIImage = nil
					selectedPhotoItem = nil
					isChangedImage = true
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Are you sure you want to clear your deck image?")
			}
			.scrollDismissesKeyboard(.interactively)
			.scrollIndicators(.hidden)
		}
	}
}

/// Methods of EditCardView.
fileprivate extension EditDeckView {
	
	private func editDeck(name: String) {
		
		guard !name.isEmpty else { return }
		
		deck.name = name
		let oldImage = deck.image
		deck.depiction = depiction.trimmingCharacters(in: .whitespacesAndNewlines)
		
		if selectedUIImage == nil {
			deck.image = "deck"
			if !isInitialImage && oldImage != "deck" {
				do {
					try storage.delete(image: oldImage)
				} catch {
					print(Errors.Image)
				}
			}
		} else if isChangedImage, let uiimage = selectedUIImage {
			do {
				deck.image = try storage.save(image: uiimage)
				if !isInitialImage && oldImage != "deck" {
					try storage.delete(image: oldImage)
				}
			} catch {
				print(Errors.Image)
			}
		}
		do {
			onSave(deck)
			try modelContext.save()
		} catch {
			print(Errors.ModelContext)
		}
	}
}

/// Toolbar.
fileprivate extension EditDeckView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
		ToolbarItem(placement: .topBarLeading) {
			Button {
				//
			} label: {
				Text("Cancel")
			}
			.tint(nil)
		}
		ToolbarItem(placement: .principal) {
			Text(title)
				.font(.headline)
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				editDeck(name: name)
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
	
	EditDeckView(
		title: "Edit Deck",
		deck: Deck(name: "", image: "deck", author: "yJuste"),
		onSave: { _ in }
	)
	.modelContainer(container)
	.environment(FileImageStorage())
}
