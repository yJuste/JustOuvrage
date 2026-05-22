//
//  EditDeckView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 5/22/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditDeckView: View {
	
	let title: String
	let deck: Deck
	let onSave: (Deck) -> Void
	let rectangle: RoundedRectangle = RoundedRectangle(cornerRadius: 10, style: .continuous)
	
	@Environment(FileImageStorage.self) private var storage
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	
	@FocusState private var focusField: FocusField?
	@State private var name: String = ""
	@State private var depiction: String = ""
	@State private var selectedPhotoItem: PhotosPickerItem?
	@State private var selectedUIImage: UIImage?
	@State private var showCancelAlert: Bool = false
	@State private var showPhotoPicker: Bool = false
	@State private var showClearImage: Bool = false
	@State private var isChangedImage: Bool = false
	@State private var isInitialImage: Bool = false
	
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
									.font(.custom("picture icon", size: 19))
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
								.padding(.horizontal, 10)
								.padding(.vertical, 5)
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
			.onChange(of: selectedPhotoItem) { _, newItem in
				guard let newItem else { return }
				Task {
					if let data = try? await newItem.loadTransferable(type: Data.self) {
						selectedUIImage = UIImage(data: data)
						isChangedImage = true
					}
				}
			}
			.onDisappear {
				selectedUIImage = nil
				selectedPhotoItem = nil
			}
			.photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
			.alert("New Deck", isPresented: $showCancelAlert) {
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
				Text("Are you sure you want to clear your image?")
			}
			.toolbar { toolbar }
			.scrollDismissesKeyboard(.interactively)
			.scrollIndicators(.hidden)
		}
	}
}

/// Methods of EditCardView.
fileprivate extension EditDeckView {
	
	private func editDeck() {
		
		let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
		
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
					print(Errors.ImageError)
				}
			}
		} else if isChangedImage, let uiimage = selectedUIImage {
			do {
				deck.image = try storage.save(image: uiimage)
				if !isInitialImage && oldImage != "deck" {
					try storage.delete(image: oldImage)
				}
			} catch {
				print(Errors.ImageError)
			}
		}
		do {
			onSave(deck)
			try modelContext.save()
		} catch {
			print(Errors.ModelContextError)
		}
	}
}

/// An interface to use to toggle a focusState.
fileprivate extension EditDeckView {
	
	private enum FocusField: Hashable {
		
		case front
		case back
	}
}


/// Toolbar.
fileprivate extension EditDeckView {
	
	@ToolbarContentBuilder private var toolbar: some ToolbarContent {
		ToolbarItem(placement: .topBarLeading) {
			Button {
				//
			} label: {
				Text("Cancel")
			}
		}
		ToolbarItem(placement: .principal) {
			Text("\(title)")
				.font(.headline)
		}
		ToolbarItem(placement: .topBarTrailing) {
			Button {
				editDeck()
				dismiss()
			} label: {
				Label("Done", systemImage: "checkmark")
			}
			.buttonStyle(.borderedProminent)
			.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
		}
	}
}

#Preview {
	
	let container = try! ModelContainer(for: Deck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
	
	EditDeckView(
		title: "Edit Deck",
		deck: Deck(
			name: "",
			image: "deck"
		),
		onSave: { _ in }
	)
	.modelContainer(container)
	.environment(FileImageStorage())
}
